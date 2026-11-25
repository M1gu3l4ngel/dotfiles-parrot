#!/bin/bash
# System-wide setup and hardening (outside $HOME) that install.sh cannot do: it needs root, and it
# installs copies, not links (a file in /etc linked to a user's repo would give that user control
# over root). Idempotent: each step checks the state and applies only what is missing.
#
# Steps:
#   1. /usr/local/sbin/anon-harden, the toggle's IPv6 and ICMP kill switch
#   2. /etc/sudoers.d/anon_toggle, NOPASSWD only for exact commands
#   3. ufw's baseline rules, IPv6 included, and turns it on
#   4. Repairs /etc/profile if it puts the current directory in PATH
#   5. Removes the user from the docker group when the Docker daemon is not installed
#   6. Copies user.js to the "pentest" Firefox profile if it exists
#   7. unattended-upgrades configuration (security patches only)
#   8. On VMware: mounts the folder shared with the host on /mnt/vmshare
#   9. Login and lock screen (slick-greeter) with the desktop wallpaper
#  10. Turns off the pentest services Parrot starts on its own, which fail
#
# Usage, from the repo root: sudo ./70-system/setup.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: this script needs root. Run it with: sudo $0"
  exit 1
fi

# The sudoers rule's user comes from SUDO_USER. Run as root directly there is no reliable way to
# know who it is for, so it fails plainly.
if [ -z "${SUDO_USER:-}" ]; then
  echo "ERROR: run it with 'sudo ./70-system/setup.sh', not as root directly."
  echo "       \$SUDO_USER is needed to write the sudoers rule."
  exit 1
fi
TARGET_USER="$SUDO_USER"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

for bin in ufw anonsurf visudo install; do
  if ! command -v "$bin" >/dev/null; then
    echo "ERROR: '$bin' is not installed. Install it first (apt install $bin)."
    exit 1
  fi
done

# A temporary file to validate the sudoers rule before installing it, removed on exit whatever
# happens.
TMP_SUDOERS=$(mktemp)
trap 'rm -f "$TMP_SUDOERS"' EXIT

# root:root 0755: the user can run it (through sudo) but not change it. If they could edit it, the
# sudoers rule's restriction would be worthless.
echo "[1/10] Installing /usr/local/sbin/anon-harden"
install -m 0755 -o root -g root "$REPO_DIR/sbin/anon-harden" /usr/local/sbin/anon-harden

# The template uses __USER__ so the user name is not published in the repo. visudo checks a
# temporary copy before it is installed: a sudoers file with a syntax error in /etc/sudoers.d/ can
# leave sudo unusable. 0440 is required (sudo ignores the file with any other mode).
echo "[2/10] Installing /etc/sudoers.d/anon_toggle (user: $TARGET_USER)"
sed "s/__USER__/$TARGET_USER/g" "$REPO_DIR/sudoers.d/anon_toggle" >"$TMP_SUDOERS"
if ! visudo -c -q -f "$TMP_SUDOERS"; then
  echo "ERROR: the sudoers rule is not valid; nothing was installed."
  exit 1
fi
install -m 0440 -o root -g root "$TMP_SUDOERS" /etc/sudoers.d/anon_toggle

# Firewall. Incoming connections nobody asked for are dropped; outgoing traffic is free (anonsurf
# filters on top); loopback is allowed for local apps; and the VPN (tun+, HTB and THM) is allowed
# on any port, for reverse shells and callbacks. On shared labs other VPN users can reach you too:
# leave no sensitive service listening while connected. IPV6=yes, or ufw filters IPv4 only.
# Each `ufw allow` is idempotent. Its normal output is dropped: ufw repeats warnings such as "be
# sure to update your rules accordingly" on every run even when nothing changes; errors still go
# to stderr and `set -e` stops the script.
echo "[3/10] Applying ufw's baseline rules"
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw allow in on lo >/dev/null
ufw allow in on tun+ from any >/dev/null
if ! grep -q "^IPV6=yes" /etc/default/ufw; then
  echo "      IPV6 was not yes, setting it"
  sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw
fi
# --force skips the "may disrupt ssh sessions [y|n]" prompt.
ufw --force enable >/dev/null
echo "      On: incoming blocked except loopback and VPN (tun+), IPv4 and IPv6"

# An empty PATH entry (`::`) means the current directory: running `ls` in a folder with a malicious
# `ls` would run that one. The base-files version is restored, keeping a copy of the current one.
echo "[4/10] Checking /etc/profile's PATH"
if grep -qE '^PATH=.*(::|=":|:")' /etc/profile; then
  BACKUP="/etc/profile.bak-$(date +%Y%m%d%H%M%S)"
  cp -p /etc/profile "$BACKUP"
  install -m 0644 -o root -g root /usr/share/base-files/profile /etc/profile
  echo "      It had an empty PATH entry. Restored (copy in $BACKUP)"
else
  echo "      Fine, no empty entries"
fi

# The docker group is the same as root (`docker run -v /:/host`). Without the daemon (podman needs
# no group) it adds nothing and stays a latent risk, so it goes. With Docker installed it only
# warns, so a workflow that uses it does not break.
echo "[5/10] Checking docker group membership"
if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx docker; then
  if command -v dockerd >/dev/null; then
    echo "      WARNING: $TARGET_USER is in the docker group (the same as root)."
    echo "      Consider 'sudo docker' or rootless podman instead."
  else
    gpasswd -d "$TARGET_USER" docker >/dev/null
    echo "      Removed from the docker group (daemon not installed). Takes effect at the"
    echo "      next login."
  fi
else
  echo "      Fine, not in the docker group"
fi

# A *.pentest profile (made with `firefox -CreateProfile pentest`) gets the hardened user.js. If it
# does not exist yet, the script says how to create it; that is not fatal.
echo "[6/10] Firefox: the pentest profile's user.js"
USERJS_SRC="$REPO_DIR/firefox/pentest.user.js"
# A glob rather than parsing `ls`: it handles paths with spaces or odd characters.
PENTEST_PROFILE=""
for dir in "$TARGET_HOME"/.mozilla/firefox/*.pentest; do
  [ -d "$dir" ] && {
    PENTEST_PROFILE="$dir"
    break
  }
done
if [ -z "$PENTEST_PROFILE" ]; then
  echo "      INFO: there is no *.pentest profile yet."
  echo "      Create it with: firefox -CreateProfile pentest"
  echo "      And run again: sudo ./70-system/setup.sh"
else
  install -m 0644 -o "$TARGET_USER" -g "$TARGET_USER" \
    "$USERJS_SRC" "$PENTEST_PROFILE/user.js"
  echo "      Copied to the pentest profile"
fi

# 52parrot-hardening.conf says what installs on its own (only parrot-security) and what does not;
# 20auto-upgrades turns on the daily run. The latter is created only if missing, to respect a value
# the user changed on purpose.
echo "[7/10] Setting up unattended-upgrades"
if ! command -v unattended-upgrade >/dev/null; then
  echo "      INFO: 'unattended-upgrades' is not installed."
  echo "      Install it with: sudo apt install unattended-upgrades"
  echo "      And run again: sudo ./70-system/setup.sh"
else
  install -m 0644 -o root -g root "$REPO_DIR/apt/52parrot-hardening.conf" \
    /etc/apt/apt.conf.d/52parrot-hardening.conf
  if [ ! -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
    install -m 0644 -o root -g root "$REPO_DIR/apt/20auto-upgrades" \
      /etc/apt/apt.conf.d/20auto-upgrades
    echo "      Created /etc/apt/apt.conf.d/20auto-upgrades"
  fi
  echo "      On: daily security patches (kernel and Tor included)"
fi

# Quick Windows <-> Linux file exchange through VMware's Shared Folders. On the host: VM Settings
# -> Options -> Shared Folders -> Always enabled -> Add, with a dedicated folder (such as
# C:\VMShare) named SHARE_NAME. Never share the whole disk: if the VM is compromised (malware,
# hostile targets), it reaches only that folder. Mount options:
#   nofail + x-systemd.automount  mounts on first access; boot does not hang if the share is off
#   allow_other + uid/gid         root mounts it, but the files belong to the user
#   umask=077                     nobody but that user can read them
SHARE_NAME="VMShare"
SHARE_MNT="/mnt/vmshare"
echo "[8/10] VMware shared folder"
if [ "$(systemd-detect-virt 2>/dev/null || true)" != "vmware" ]; then
  echo "      Not a VMware VM; skipped"
elif ! command -v vmhgfs-fuse >/dev/null; then
  echo "      INFO: vmhgfs-fuse is missing. Install it with: sudo apt install open-vm-tools-desktop"
elif ! vmware-hgfsclient 2>/dev/null | grep -qx "$SHARE_NAME"; then
  echo "      INFO: VMware shares no folder named '$SHARE_NAME'."
  echo "      Set it up in VM Settings -> Options -> Shared Folders and run again."
else
  TARGET_UID=$(id -u "$TARGET_USER")
  TARGET_GID=$(id -g "$TARGET_USER")
  mkdir -p "$SHARE_MNT"
  if ! grep -q "^\.host:/$SHARE_NAME " /etc/fstab; then
    cp -p /etc/fstab "/etc/fstab.bak-$(date +%Y%m%d%H%M%S)"
    echo ".host:/$SHARE_NAME $SHARE_MNT fuse.vmhgfs-fuse nofail,x-systemd.automount,allow_other,uid=$TARGET_UID,gid=$TARGET_GID,umask=077 0 0" >>/etc/fstab
    echo "      Added to /etc/fstab (previous version copied to /etc/fstab.bak-*)"
  fi
  systemctl daemon-reload
  systemctl start "$(systemd-escape -p --suffix=automount "$SHARE_MNT")"
  # A shortcut in the home folder, so the mount path need not be remembered.
  sudo -u "$TARGET_USER" ln -sfn "$SHARE_MNT" "$TARGET_HOME/VMShare"
  # A bookmark in the file manager's sidebar (Nautilus reads gtk-3.0's bookmarks in GTK4 too),
  # added only if missing.
  BOOKMARKS="$TARGET_HOME/.config/gtk-3.0/bookmarks"
  if ! grep -qs "^file://$TARGET_HOME/VMShare " "$BOOKMARKS"; then
    sudo -u "$TARGET_USER" mkdir -p "$(dirname "$BOOKMARKS")"
    echo "file://$TARGET_HOME/VMShare VMShare" | sudo -u "$TARGET_USER" tee -a "$BOOKMARKS" >/dev/null
  fi
  echo "      Available on $SHARE_MNT (shortcut: ~/VMShare)"
fi

# The same wallpaper as the desktop (lightdm/slick-greeter.conf), copied to /usr/share/backgrounds
# because the lightdm user cannot read home folders. Parrot's config is saved once, to .parrot: a
# later run does not overwrite it with ours.
GREETER_CONF=/etc/lightdm/slick-greeter.conf
echo "[9/10] Login and lock screen"
if ! command -v slick-greeter >/dev/null; then
  echo "      slick-greeter is not installed; skipped"
else
  install -m 0644 -o root -g root "$REPO_DIR/../assets/wallpaper.jpg" \
    /usr/share/backgrounds/dotfiles-wallpaper.jpg
  if [ -f "$GREETER_CONF" ] && [ ! -f "$GREETER_CONF.parrot" ]; then
    cp -p "$GREETER_CONF" "$GREETER_CONF.parrot"
    echo "      Original config saved to $GREETER_CONF.parrot"
  fi
  install -m 0644 -o root -g root "$REPO_DIR/lightdm/slick-greeter.conf" "$GREETER_CONF"
  echo "      Desktop wallpaper applied (shows at the next login or lock)"
fi

# Parrot enables them at boot with no configuration, so they fail on every start (the red lines
# after the logo) and make it longer; a fake access point or a DHCP server must not come up
# unasked either. cpupower-gui fails because the VM has no CPU frequency control. Disabled, not
# masked: still available with `sudo systemctl start <service>`, and apt keeps the disabled state
# when it updates the package.
echo "[10/10] Pentest services that start on their own"
for svc in hostapd-wpe isc-dhcp-server sslh cpupower-gui; do
  if ! systemctl cat "$svc.service" >/dev/null 2>&1; then
    continue
  fi
  if systemctl --quiet is-enabled "$svc.service" 2>/dev/null; then
    systemctl --quiet disable --now "$svc.service"
    systemctl reset-failed "$svc.service" 2>/dev/null || true
    echo "      $svc disabled"
  else
    echo "      $svc was already disabled"
  fi
done

echo
echo "Setup complete. Check with:"
echo "  sudo ufw status verbose"
echo "  sudo -l -U $TARGET_USER          # must list only anonsurf/anon-harden as NOPASSWD"
echo "  sudo unattended-upgrade --dry-run --debug"
