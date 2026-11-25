#!/usr/bin/env bash
# Runs install.sh and uninstall.sh against a throwaway HOME and checks what they leave behind: the
# four link states, the backup of a real file, the original put back when ln fails, the signing key
# carried to ~/.gitconfig.local, a second run that changes nothing and an uninstall that restores
# everything. The real HOME is never touched. tools/check.sh and the CI run it.
#
# The Claude Code layer comes from CLAUDE_LAYER_DIR, or the dotfiles-windows clone next to the
# repo, as in install.sh.
#
# Each check is a shell expression in single quotes that eval runs later, after the run it follows,
# so it reads CODE and the files of that moment: SC2016 and SC2034 do not apply.
# shellcheck disable=SC2016,SC2034

# No -e: a failing run or check is counted and reported, not a reason to stop.
set -uo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
LAYER="${CLAUDE_LAYER_DIR:-$HOME/dotfiles-windows/50-claude}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
T=$WORK/home
OUT=$WORK/out.txt
FAILS=0
CODE=0

if [ ! -f "$LAYER/links.json" ] || ! command -v node >/dev/null; then
  echo "SKIP the Claude Code layer or node is missing ($LAYER)"
  exit 0
fi

check() {
  if eval "$2"; then
    echo "PASS $1"
  else
    echo "FAIL $1"
    FAILS=$((FAILS + 1))
  fi
}
# No session bus and no user systemd: the desktop settings must warn, never reach the real session.
run() {
  env -u DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR=/nonexistent HOME="$T" CLAUDE_LAYER_DIR="$LAYER" \
    PATH="${EXTRA_PATH:-}$PATH" "$@" >"$OUT" 2>&1
  CODE=$?
}
count_links() { find "$T" -type l | wc -l; }

mkdir -p "$T/.config"
expected=$(DOTFILES_DIR=$REPO HOME=$T CLAUDE_LAYER_DIR=$LAYER bash -c \
  '. "$DOTFILES_DIR/lib/links.sh"; add_claude_layer_links; echo ${#LINKS[@]}')

# One of each state before installing: a real file, a link to an old repo path (stale), a link to
# a look-alike folder next to the repo (foreign), and a real ~/.gitconfig with a signing key.
echo "mine" >"$T/.zshrc"
printf '[user]\n\tsigningkey = ABCDEF0123456789\n' >"$T/.gitconfig"
ln -s "$REPO/old/kitty" "$T/.config/kitty"
mkdir -p "$T/.claude"
ln -s "${REPO}-lookalike/CLAUDE.md" "$T/.claude/CLAUDE.md"

run "$REPO/install.sh" --check
check "check before installing exits 1 and names each state" \
  '[ $CODE -eq 1 ] && grep -q "RUTA VIEJA" "$OUT" && grep -q "AJENO" "$OUT" && grep -q "FALTA" "$OUT"'

run "$REPO/install.sh" --dry-run
check "dry run exits 0" '[ $CODE -eq 0 ]'
check "dry run changes nothing" \
  '[ "$(count_links)" -eq 2 ] && [ "$(cat "$T/.zshrc")" = mine ] && [ ! -e "$T/.claude/settings.json" ] && [ ! -d "$T/.gnupg" ]'
check "dry run names the backup and the relink" \
  'grep -q "Respaldaría ~/.zshrc" "$OUT" && grep -q "ruta vieja: ~/.config/kitty" "$OUT"'

run "$REPO/install.sh"
check "install exits 0" '[ $CODE -eq 0 ]'
check "a real file is backed up" '[ "$(cat "$T/.zshrc.pre-dotfiles.bak")" = mine ]'
check "a stale link is redone without a backup" \
  '[ "$(readlink "$T/.config/kitty")" = "$REPO/20-terminal/kitty/.config/kitty" ] && [ ! -e "$T/.config/kitty.pre-dotfiles.bak" ] && [ ! -L "$T/.config/kitty.pre-dotfiles.bak" ]'
check "a look-alike link is foreign and backed up" \
  '[ -L "$T/.claude/CLAUDE.md.pre-dotfiles.bak" ] && [ "$(readlink "$T/.claude/CLAUDE.md")" = "$LAYER/CLAUDE.md" ]'
check "the Claude Code layer is linked from links.json" '[ "$(readlink "$T/.claude/panel")" = "$LAYER/panel" ]'
check "settings.json is created with the layer hooks" \
  'grep -q "panel-session-start.mjs" "$T/.claude/settings.json" && grep -q "$T/.claude" "$T/.claude/settings.json"'
check "the signing key moves to .gitconfig.local" \
  '[ "$(HOME=$T git config --get user.signingkey)" = ABCDEF0123456789 ] && [ "$(HOME=$T git config --get user.name)" = M1gu3l4ngel ] && [ -f "$T/.gitconfig.pre-dotfiles.bak" ]'
check "the GnuPG home is created with mode 700" '[ "$(stat -c %a "$T/.gnupg")" = 700 ]'

run "$REPO/install.sh" --check
check "check after installing exits 0 with all $expected links" \
  '[ $CODE -eq 0 ] && grep -q "Todo instalado: $expected enlaces" "$OUT"'

run "$REPO/install.sh"
check "a second run changes no link" \
  'grep -q "$expected enlaces ya estaban bien" "$OUT" && ! grep -qE "Enlazado:|Copia de seguridad:|ruta vieja" "$OUT"'

# ln fails right after the backup: the original has to come back.
rm "$T/.config/dunst" && echo "my dunst" >"$T/.config/dunst"
mkdir -p "$WORK/bin" && printf '#!/bin/sh\nexit 1\n' >"$WORK/bin/ln" && chmod +x "$WORK/bin/ln"
EXTRA_PATH="$WORK/bin:" run "$REPO/install.sh"
check "a failed ln exits non-zero" '[ $CODE -ne 0 ] && grep -q "No se pudo crear el enlace" "$OUT"'
check "a failed ln puts the original back" \
  '[ "$(cat "$T/.config/dunst")" = "my dunst" ] && [ ! -e "$T/.config/dunst.pre-dotfiles.bak" ]'
rm "$T/.config/dunst"
run "$REPO/install.sh"

run "$REPO/uninstall.sh" --dry-run
check "uninstall dry run changes nothing" '[ -L "$T/.zshrc" ] && [ -e "$T/.zshrc.pre-dotfiles.bak" ]'

run "$REPO/uninstall.sh"
check "uninstall restores the original file" '[ ! -L "$T/.zshrc" ] && [ "$(cat "$T/.zshrc")" = mine ]'
check "uninstall removes the layer links" '[ ! -L "$T/.claude/panel" ]'
check "uninstall leaves no repo link behind" \
  '[ -z "$(find "$T" -type l \( -lname "$REPO/*" -o -lname "$LAYER/*" \))" ]'

echo "$FAILS failed"
[ "$FAILS" -eq 0 ]
