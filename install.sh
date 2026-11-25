#!/usr/bin/env bash
# Links each configuration file of the repo to where its program reads it (lib/links.sh), plus the
# Claude Code layer from the dotfiles-windows clone, and merges ~/.claude/settings.json. Anything
# in the way is kept as a .pre-dotfiles.bak backup, which ./uninstall.sh restores. What is already
# right is skipped, so it runs again safely, and bootstrap.sh calls it.

set -euo pipefail

# The script's own folder, not ~/dotfiles: a clone elsewhere would otherwise get links to a folder
# that does not exist, and the whole desktop would break.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".pre-dotfiles.bak"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "    ${GREEN}✓${NC} $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; }
planned() { echo -e "    ${YELLOW}~${NC} $1"; }
die() {
  echo -e "    ${RED}✗ $1${NC}" >&2
  exit 1
}
# ~ instead of the full home: shorter, and the output does not show the user name.
short() { echo "${1/#"$HOME"/\~}"; }

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run | --check]

  (no option)  links what is missing, merges ~/.claude/settings.json and applies
               the desktop settings
  --dry-run    shows what it would link, back up, redo or set, changing nothing
  --check      reports the state of each link and of ~/.claude/settings.json;
               exits with 1 if something is wrong
  -h, --help   this help
EOF
  exit 0
}

MODE=install
for arg in "$@"; do
  case "$arg" in
    --dry-run) MODE=dry-run ;;
    --check) MODE=check ;;
    -h | --help) usage ;;
    *) die "Unknown option: $arg (see --help)" ;;
  esac
done

# Copied out of the repo, the sources do not exist: fail with a clear message instead of making
# broken links.
if [ ! -f "$DOTFILES_DIR/lib/links.sh" ]; then
  die "install.sh must run inside the repo ($DOTFILES_DIR/lib/links.sh does not exist)"
fi
# shellcheck source=lib/links.sh
. "$DOTFILES_DIR/lib/links.sh"
LAYER=yes
if ! add_claude_layer_links; then
  LAYER=no
  warn "Claude Code layer skipped: $(short "$CLAUDE_LAYER_DIR")/links.json or node is missing"
  warn "Clone it with: git clone https://github.com/M1gu3l4ngel/dotfiles-windows.git ~/dotfiles-windows"
fi
SETTINGS_TOOL="$CLAUDE_LAYER_DIR/tools/install-settings.mjs"

CHANGED=0
ALREADY=0

# Runs a change, or with --dry-run only names it. The first argument says what it does. A failure
# warns instead of stopping: these are side settings (dconf, systemd --user) that a session
# without a desktop bus cannot apply, and the links matter more.
change() {
  local what=$1
  shift
  if [ "$MODE" = dry-run ]; then
    planned "Pending: $what"
  elif "$@" >/dev/null 2>&1; then
    ok "$what"
  else
    warn "Could not apply: $what"
    return 0
  fi
  CHANGED=$((CHANGED + 1))
}

# Links source at target according to link_state. A foreign file is moved to .pre-dotfiles.bak
# first, with a date when a backup already exists: an older one may be the only copy of the
# original. If ln fails, the backup goes back, so the user never loses the file.
create_symlink() {
  local source=$1 target=$2 state backup=""
  if [ ! -e "$source" ]; then
    warn "Missing from the repo, skipped: $(short "$source")"
    return 0
  fi
  state=$(link_state "$source" "$target")
  if [ "$state" = ok ]; then
    ALREADY=$((ALREADY + 1))
    return 0
  fi
  CHANGED=$((CHANGED + 1))
  if [ "$state" = foreign ]; then
    backup="${target}${BACKUP_SUFFIX}"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      backup="${backup}.$(date +%Y%m%d%H%M%S)"
    fi
  fi
  if [ "$MODE" = dry-run ]; then
    case "$state" in
      missing) planned "Would link: $(short "$target")" ;;
      stale) planned "Would redo a link to an old path: $(short "$target") (was $(short "$(readlink -- "$target")"))" ;;
      foreign) planned "Would back up $(short "$target") to $(short "$backup") and link it" ;;
    esac
    return 0
  fi
  case "$state" in
    stale)
      # No trailing slash: rm removes the link itself, never what a folder link points to.
      warn "Link to an old path, redone: $(short "$target") (was $(short "$(readlink -- "$target")"))"
      rm -- "$target"
      ;;
    foreign)
      warn "Backup: $(short "$target") -> $(short "$backup")"
      mv -- "$target" "$backup"
      ;;
  esac
  mkdir -p "$(dirname "$target")"
  if ! ln -s -- "$source" "$target"; then
    if [ -n "$backup" ]; then
      mv -- "$backup" "$target"
      warn "Original restored: $(short "$target")"
    fi
    die "Could not create the link: $(short "$target")"
  fi
  ok "Linked: $(short "$target")"
}

# --check: the same states an install would act on, changing nothing.
check_installation() {
  local link state bad=0
  local -A labels=([ok]="ok" [missing]="MISSING" [stale]="STALE" [foreign]="FOREIGN")
  for link in "${LINKS[@]}"; do
    state=$(link_state "${link%%|*}" "${link#*|}")
    [ "$state" = ok ] || bad=$((bad + 1))
    printf '  %-11s %s\n' "${labels[$state]}" "$(short "${link#*|}")"
  done
  if [ "$(git -C "$DOTFILES_DIR" config --get core.hooksPath)" = githooks ]; then
    printf '  %-11s %s\n' ok "git post-merge on"
  else
    printf '  %-11s %s\n' MISSING "git post-merge (core.hooksPath)"
    bad=$((bad + 1))
  fi
  if [ "$LAYER" = yes ]; then
    node "$SETTINGS_TOOL" --check || bad=$((bad + 1))
  else
    printf '  %-11s %s\n' MISSING "Claude Code layer ($(short "$CLAUDE_LAYER_DIR"))"
    bad=$((bad + 1))
  fi
  # The identity is per person, in ~/.gitconfig.local, not in the linked 15-git/gitconfig:
  # without it every commit fails. bootstrap.sh writes it; install.sh only reports it.
  if [ -n "$(git config --get user.name)" ] && [ -n "$(git config --get user.email)" ]; then
    printf '  %-11s %s\n' ok "git identity"
  else
    printf '  %-11s %s\n' MISSING \
      "git identity in ~/.gitconfig.local (./bootstrap.sh --git-name <name> --git-email <email>)"
    bad=$((bad + 1))
  fi
  echo
  if [ "$bad" -eq 0 ]; then
    ok "All installed: ${#LINKS[@]} links, ~/.claude/settings.json and git identity"
    exit 0
  fi
  echo -e "    ${RED}✗${NC} $bad checks failed. To fix them: ./install.sh"
  exit 1
}

[ "$MODE" = check ] && check_installation
[ "$MODE" = dry-run ] && echo "    Dry run (--dry-run): nothing is changed."

# ~/.gnupg goes before its gpg-agent.conf link: mkdir -p would create it 755, and gpg warns about
# "unsafe permissions" on an open home folder.
if [ ! -d "$HOME/.gnupg" ]; then
  change "Created ~/.gnupg with mode 700" mkdir -m 700 "$HOME/.gnupg"
elif [ "$(stat -c %a "$HOME/.gnupg")" != 700 ]; then
  change "Mode 700 on ~/.gnupg" chmod 700 "$HOME/.gnupg"
fi

# ~/.gitconfig becomes a link to the public 15-git/gitconfig, which has no signing key. A key set
# in the old real file is carried to ~/.gitconfig.local first, or commits would stop being signed
# right after the install. The old file itself is kept as the usual .pre-dotfiles.bak.
signing_key=""
if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
  signing_key=$(git config --file "$HOME/.gitconfig" --get user.signingkey || true)
fi
if [ -n "$signing_key" ] &&
  [ -z "$(git config --file "$HOME/.gitconfig.local" --get user.signingkey 2>/dev/null || true)" ]; then
  change "Git signing key copied to ~/.gitconfig.local" \
    git config --file "$HOME/.gitconfig.local" user.signingkey "$signing_key"
fi

for link in "${LINKS[@]}"; do
  create_symlink "${link%%|*}" "${link#*|}"
done

# bspwmrc loads ~/.config/wallpaper.jpg. Only linked when there is none, so a wallpaper of the
# user's survives a second run.
if [ ! -e "$HOME/.config/wallpaper.jpg" ] && [ ! -L "$HOME/.config/wallpaper.jpg" ]; then
  change "Default wallpaper: ~/.config/wallpaper.jpg" \
    ln -s "$DOTFILES_DIR/assets/wallpaper.jpg" "$HOME/.config/wallpaper.jpg"
fi

# settarget and the demo mode (.zshrc) share their state with polybar's modules in STATE_DIR: data
# that changes, not configuration, so it does not live under ~/.config. The same path is in .zshrc
# and in the scripts that read it.
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
# Where version 2.0.0 and earlier kept that state, with anon_state, which the anonymity toggle no
# longer writes.
OLD_STATE_DIR="$HOME/.config/bin"

has_old_state() {
  local f
  for f in target demo; do
    [ -f "$OLD_STATE_DIR/$f" ] && [ ! -e "$STATE_DIR/$f" ] && return 0
  done
  [ -f "$OLD_STATE_DIR/anon_state" ]
}

# Moves target and demo without overwriting a newer copy, and removes the folder if it is left empty.
move_old_state() {
  local f
  mkdir -p "$STATE_DIR" || return 1
  for f in target demo; do
    if [ -f "$OLD_STATE_DIR/$f" ] && [ ! -e "$STATE_DIR/$f" ]; then
      mv -- "$OLD_STATE_DIR/$f" "$STATE_DIR/$f" || return 1
    fi
  done
  rm -f -- "$OLD_STATE_DIR/anon_state"
  rmdir -- "$OLD_STATE_DIR" 2>/dev/null || true
}

if has_old_state; then
  change "Moved the target and demo state from ~/.config/bin to ${STATE_DIR/#$HOME/\~}" move_old_state
fi

# Created empty, so victim_to_hack.sh does not fail when polybar starts before the first settarget.
# Not while an old target is still in place: the move above brings it (in a dry run it has not yet).
create_target_file() { mkdir -p "$STATE_DIR" && : >"$STATE_DIR/target"; }
if [ ! -f "$STATE_DIR/target" ] && [ ! -f "$OLD_STATE_DIR/target" ]; then
  change "Created an empty ${STATE_DIR/#$HOME/\~}/target" create_target_file
fi

# Merged, never linked: it holds this machine's home and what Claude Code writes on it. The tool
# adds the template's missing hooks, rules and status line with a dated backup.
if [ "$LAYER" = yes ]; then
  if [ "$MODE" = dry-run ]; then
    node "$SETTINGS_TOOL" --check >/dev/null || planned "Would merge what is missing into ~/.claude/settings.json (details: ./install.sh --check)"
  else
    node "$SETTINGS_TOOL"
  fi
fi

# githooks/post-merge runs this script after every pull with changes, so a moved or new file is
# linked without remembering to run it. Only in a clone: a copied folder has no git config.
if [ -d "$DOTFILES_DIR/.git" ] && [ "$(git -C "$DOTFILES_DIR" config --get core.hooksPath)" != githooks ]; then
  change "Turned on git post-merge: every git pull runs install.sh again" \
    git -C "$DOTFILES_DIR" config core.hooksPath githooks
fi

# libadwaita (Nautilus) takes dark mode from this setting, stored in dconf, not in a file to link:
# without it, Nautilus opens light on a dark desktop.
if command -v gsettings >/dev/null &&
  [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" != "'prefer-dark'" ]; then
  change "Dark mode on for GTK4 apps" gsettings set org.gnome.desktop.interface color-scheme prefer-dark
fi

# Apps that open a folder (Firefox's "Show in folder") use the inode/directory handler, which a
# code editor had taken.
FOLDER_APP="org.gnome.Nautilus.desktop"
if command -v xdg-mime >/dev/null && [ -f "/usr/share/applications/$FOLDER_APP" ] &&
  [ "$(xdg-mime query default inode/directory)" != "$FOLDER_APP" ]; then
  change "Folders open in the file manager (Nautilus)" xdg-mime default "$FOLDER_APP" inode/directory
fi

# Nautilus pulls in localsearch, which indexes every file in the background (constant CPU and
# disk). mask keeps it from starting even when Nautilus asks; search still walks the folders.
if command -v systemctl >/dev/null &&
  [ "$(systemctl --user is-enabled localsearch-3.service 2>/dev/null)" != "masked" ]; then
  change "File indexer (localsearch) turned off" systemctl --user mask --now localsearch-3.service
fi

if [ "$MODE" = dry-run ]; then
  ok "$CHANGED changes to make, $ALREADY links already fine. To apply them: ./install.sh"
elif [ "$CHANGED" -eq 0 ]; then
  ok "Nothing to change: the $ALREADY links were already fine"
else
  ok "$CHANGED changes made, $ALREADY links already fine"
  echo "    To load them: exec zsh in each terminal and Super+Alt+R"
fi
