#!/bin/sh
# Shows the main network interface's IPv4 in polybar's ethernet_status module (bar/ethernet_bar);
# polybar runs it every second. The interface is found on its own: the first with an IPv4 that is
# not loopback, a tunnel or VPN (tun, wg) or a container network (docker, br-, veth, virbr), so it
# works with ens33 (VMware), eth0 or enp0s3 alike.
#
# One call to `ip`, the rest with sh builtins, to start no extra process every second. No `set -e`
# on purpose: if something fails, the bar must still show a text, not go blank.

set -u

# nf-md-ethernet (U+F0200) as an escape: editing tools drop private use glyphs (PUA) written
# literally.
ICON=$(printf '\363\260\210\200')

# `demo on` (a .zshrc function) writes fake values to DEMO_FILE for screenshots and videos; while it
# exists they replace the real ones. Format: "<ethernet> <vpn> <target_ip> <target_name>
# <prompt_name>".
DEMO_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/demo"
ip_address=""
[ -r "$DEMO_FILE" ] && read -r ip_address _ <"$DEMO_FILE"

if [ -z "$ip_address" ]; then
  # `ip -4 -br addr` prints "<interface> <state> <ip>/<prefix> ...".
  while read -r iface _ addr _; do
    case "$iface" in
      lo | tun* | wg* | docker* | br-* | veth* | virbr*) continue ;;
      *) ;;
    esac
    ip_address=${addr%%/*}
    break
  done <<EOF
$(ip -4 -br addr show 2>/dev/null)
EOF
fi

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

# With an IP: a cyan icon (local network) and the IP highlighted. With no network: all grey.
if [ -n "$ip_address" ]; then
  echo "%{F${INFO}}${ICON} %{F${STRONG}}${ip_address}%{F-}"
else
  echo "%{F${MUTED}}${ICON} Disconnected%{F-}"
fi
