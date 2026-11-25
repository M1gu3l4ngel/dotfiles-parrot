#!/usr/bin/env bash
# Undoes install.sh: removes the links that point to this repo and restores the .pre-dotfiles.bak
# copy install.sh kept of each original file. Only this repo's links are touched: a real file or a
# link elsewhere stays as it is. It does not remove apt packages, undo 70-system/setup.sh's
# hardening or the settings install.sh applies without links (GTK4 dark mode, default file manager,
# indexer turned off). A second run finds nothing to remove.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The same suffix install.sh uses for its backups.
BACKUP_SUFFIX=".pre-dotfiles.bak"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "    ${GREEN}✓${NC} $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; }
die() {
  echo -e "    ${RED}✗ $1${NC}" >&2
  exit 1
}
# ~ instead of the full home: shorter, and the output does not show the user name.
short() { echo "${1/#"$HOME"/\~}"; }

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [--dry-run]

  (no option)  removes the links of this repo and of the Claude Code layer and
               restores the .pre-dotfiles.bak copies
  --dry-run    shows what it would do, changing nothing
  -h, --help   this help
EOF
  exit 0
}

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h | --help) usage ;;
    *) die "Unknown option: $arg (see --help)" ;;
  esac
done

if [ ! -f "$DOTFILES_DIR/lib/links.sh" ]; then
  die "uninstall.sh must run inside the repo ($DOTFILES_DIR/lib/links.sh does not exist)"
fi

# The same targets install.sh creates, from the shared list.
# shellcheck source=lib/links.sh
. "$DOTFILES_DIR/lib/links.sh"
add_claude_layer_links || warn "Claude Code layer skipped: $(short "$CLAUDE_LAYER_DIR")/links.json or node is missing"
# The wallpaper is not in the map because install.sh only links it when there is no wallpaper of
# the user's; when the link is the repo's, it goes too.
LINKS+=("$DOTFILES_DIR/assets/wallpaper.jpg|$HOME/.config/wallpaper.jpg")

REMOVED=0
RESTORED=0

# With --dry-run, `act` only describes; otherwise it runs the command.
act() {
  [ "$DRY_RUN" -eq 1 ] || "$@"
}

# Puts the original back. Only the undated copy, the one the first install kept: dated copies (from
# reinstalls) are left to check by hand, since there is no telling which one is right.
restore_backup() {
  local target="$1" backup="$1$BACKUP_SUFFIX"
  if [ -e "$backup" ] || [ -L "$backup" ]; then
    act mv -- "$backup" "$target"
    ok "$([ "$DRY_RUN" -eq 1 ] && echo "Would restore" || echo "Restored"): $(short "$target")"
    RESTORED=$((RESTORED + 1))
  fi
  local extra
  for extra in "$backup".*; do
    if [ -e "$extra" ] || [ -L "$extra" ]; then
      warn "Dated copy not restored (check it by hand): $(short "$extra")"
    fi
  done
  return 0
}

unlink_target() {
  local source=$1 target=$2 state
  state=$(link_state "$source" "$target")
  if [ "$state" = ok ] || [ "$state" = stale ]; then
    act rm -- "$target"
    ok "$([ "$DRY_RUN" -eq 1 ] && echo "Would remove the link" || echo "Link removed"): $(short "$target")"
    REMOVED=$((REMOVED + 1))
    restore_backup "$target"
  elif [ "$state" = foreign ]; then
    # A real file or a link elsewhere: not this repo's, left alone.
    warn "Not a link of this repo, left alone: $(short "$target")"
  else
    # Nothing at the target (an interrupted uninstall, say): a remaining copy is still restored.
    restore_backup "$target"
  fi
}

[ "$DRY_RUN" -eq 1 ] && echo "    Dry run (--dry-run): nothing is changed."
for link in "${LINKS[@]}"; do
  unlink_target "${link%%|*}" "${link#*|}"
done

if [ "$DRY_RUN" -eq 1 ]; then
  ok "Would remove $REMOVED links and restore $RESTORED copies"
  echo "    To apply it: ./uninstall.sh"
elif [ "$REMOVED" -eq 0 ] && [ "$RESTORED" -eq 0 ]; then
  ok "There were no links of this repo to remove"
else
  ok "$REMOVED links removed, $RESTORED copies restored"
  echo "    Log out and back in to apply the original configuration"
fi
