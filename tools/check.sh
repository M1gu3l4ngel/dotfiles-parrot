#!/usr/bin/env bash
# The repo's quality and security checks, the same ones CI (.github/workflows/ci.yml) runs on every
# push, to run locally before a commit: ./tools/check.sh
#
# What it checks:
#   1. Syntax of every shell script (bash -n, sh -n)
#   2. shellcheck on those scripts (unquoted variables, bashisms in sh such as the $UID that broke
#      launch.sh) and shfmt formatting
#   3. .zshrc syntax (zsh -n)
#   4. Syntax of Neovim's Lua config
#   5. Valid JSON (oh-my-posh theme, lazy-lock, VSCodium)
#   6. The sudoers rule and the XKB keymap (visudo and xkbcomp)
#   7. Public repo hygiene: no font binaries, /home/<user> paths or CRLF; bilingual docs in sync,
#      comments in English and the panel's format (dotfiles-windows tools); install tests
#      (tools/test-install.sh)
#   8. Secrets in the whole history with gitleaks (if installed)
#
# A missing tool is reported and skipped locally; CI installs all of them. Exits non-zero if any
# check fails.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

FAILED=0
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
skip() { echo -e "${YELLOW}-${NC} $1"; }
fail() {
  echo -e "${RED}✗${NC} $1"
  FAILED=1
}
have() { command -v "$1" >/dev/null; }

# Shell scripts found by their shebang, not their extension: bspwmrc and polybar's scripts have no
# .sh. zsh is left out: shellcheck does not support it.
SH_SCRIPTS=()
BASH_SCRIPTS=()
while IFS= read -r file; do
  # `read` rather than `$(head -n1 ...)`: on binary files (images, fonts) command substitution warns
  # about null bytes.
  first=""
  IFS= read -r first <"$file" 2>/dev/null
  case "$first" in
    '#!'*bash*) BASH_SCRIPTS+=("$file") ;;
    # dash is Debian's /bin/sh: POSIX, checked like sh.
    '#!'*/sh | '#!'*'env sh' | '#!'*dash*) SH_SCRIPTS+=("$file") ;;
    *) ;;
  esac
done < <(git ls-files)

errors=0
for f in "${BASH_SCRIPTS[@]}"; do
  if ! bash -n "$f"; then
    fail "bash syntax: $f"
    errors=1
  fi
done
for f in "${SH_SCRIPTS[@]}"; do
  if ! sh -n "$f"; then
    fail "sh syntax: $f"
    errors=1
  fi
done
[ "$errors" -eq 0 ] && pass "Syntax of $((${#BASH_SCRIPTS[@]} + ${#SH_SCRIPTS[@]})) shell scripts"

if have shellcheck; then
  if shellcheck "${BASH_SCRIPTS[@]}" "${SH_SCRIPTS[@]}"; then
    pass "shellcheck: no warnings"
  else
    fail "shellcheck found problems (details above)"
  fi
else
  skip "shellcheck not installed (apt install shellcheck)"
fi

# The same options Neovim formats with (30-editor/nvim/.../configs/conform.lua): 2 spaces and
# indented `case` branches. -d shows the difference without touching anything; to apply it:
# shfmt -i 2 -ci -w <file>.
if have shfmt; then
  if shfmt -i 2 -ci -d "${BASH_SCRIPTS[@]}" "${SH_SCRIPTS[@]}"; then
    pass "shfmt formatting"
  else
    fail "Unformatted scripts (differences above; apply with shfmt -i 2 -ci -w)"
  fi
else
  skip "shfmt not installed (apt install shfmt)"
fi

if have zsh; then
  if zsh -n 10-shell/zsh/.zshrc; then pass ".zshrc syntax"; else fail "zsh syntax: 10-shell/zsh/.zshrc"; fi
else
  skip "zsh not installed"
fi

mapfile -t LUA_FILES < <(git ls-files '*.lua')
LUAC=""
for c in luac5.1 luac; do have "$c" && {
  LUAC=$c
  break
}; done
errors=0
if [ -n "$LUAC" ]; then
  for f in "${LUA_FILES[@]}"; do "$LUAC" -p "$f" || {
    fail "Lua syntax: $f"
    errors=1
  }; done
  [ "$errors" -eq 0 ] && pass "Syntax of ${#LUA_FILES[@]} Lua files ($LUAC)"
elif have nvim; then
  # Without luac, Neovim itself (LuaJIT) compiles each file without running it.
  for f in "${LUA_FILES[@]}"; do
    out=$(nvim --headless -u NONE -c "lua local ok, err = loadfile('$f'); if not ok then io.stderr:write(err) end" -c 'qa!' 2>&1)
    [ -n "$out" ] && {
      fail "Lua syntax: $out"
      errors=1
    }
  done
  [ "$errors" -eq 0 ] && pass "Syntax of ${#LUA_FILES[@]} Lua files (nvim)"
else
  skip "neither luac nor nvim installed: Lua skipped"
fi

# VSCodium's settings are JSONC (they allow // comments): comment lines are removed before parsing
# them as JSON.
STRIP_JSONC='import json, re, sys; json.loads(re.sub(r"(?m)^\s*//.*$", "", open(sys.argv[1]).read()))'
errors=0
while IFS= read -r f; do
  if [[ "$f" == 30-editor/vscodium/* ]]; then
    python3 -c "$STRIP_JSONC" "$f" >/dev/null 2>&1
  else
    python3 -m json.tool "$f" >/dev/null 2>&1
  fi || {
    fail "Invalid JSON: $f"
    errors=1
  }
done < <(git ls-files '*.json')
[ "$errors" -eq 0 ] && pass "Valid JSON"

if have visudo || [ -x /usr/sbin/visudo ]; then
  tmp=$(mktemp)
  sed 's/__USER__/root/g' 70-system/sudoers.d/anon_toggle >"$tmp"
  if PATH="$PATH:/usr/sbin" visudo -c -q -f "$tmp"; then pass "Valid sudoers rule"; else fail "Invalid sudoers: 70-system/sudoers.d/anon_toggle"; fi
  rm -f "$tmp"
else
  skip "visudo not available"
fi
if have xkbcomp; then
  tmp=$(mktemp)
  if xkbcomp -w 0 -I"25-desktop/xkb/.config/xkb" 25-desktop/xkb/.config/xkb/keymap.xkb "$tmp" 2>/dev/null; then
    pass "XKB keymap compiles"
  else
    fail "XKB keymap does not compile: 25-desktop/xkb/.config/xkb/keymap.xkb"
  fi
  rm -f "$tmp"
else
  skip "xkbcomp not installed (apt install x11-xkb-utils)"
fi

# Fonts are installed by bootstrap.sh; versioning them bloats the repo and brings license problems.
fonts=$(git ls-files '*.ttf' '*.otf')
if [ -z "$fonts" ]; then pass "No versioned font binaries"; else fail "Versioned fonts: $fonts"; fi
# Absolute paths to a given home leak the user name and break the repo on other machines (use $HOME
# or ~).
paths=$(git grep -nIE '/home/[a-z_][a-z0-9_-]*/' || true)
if [ -z "$paths" ]; then pass "No hardcoded /home/<user> paths"; else
  fail "Hardcoded home paths:"
  echo "$paths"
fi
# Both the index and the working tree: .gitattributes fixes new checkouts, but a file committed
# with CRLF before it, or edited on Windows, still breaks a script on Linux.
crlf=$(git ls-files --eol | grep -E '^[iw]/(crlf|mixed)|[[:space:]]w/(crlf|mixed)' | cut -f2 || true)
if [ -z "$crlf" ]; then pass "LF line endings"; else
  fail "CRLF line endings in:"
  echo "$crlf"
fi

# The bilingual docs and panel checkers are the ones dotfiles-windows shares with every repo: its
# clone next to this one, or CLAUDE_LAYER_DIR in CI. The install tests need the layer too.
LAYER_DIR="${CLAUDE_LAYER_DIR:-$HOME/dotfiles-windows/50-claude}"

# Runs a check that needs the layer and node. Skipped only locally: the CI checks the layer out,
# so a missing layer there is a broken step. Usage: layer_check <label> <command...>
layer_check() {
  local label=$1 out
  shift
  if ! have node || [ ! -f "$LAYER_DIR/links.json" ]; then
    if [ -n "${CI:-}" ]; then fail "$label: node or $LAYER_DIR is missing"; else skip "$label: node or $LAYER_DIR is missing"; fi
  elif out=$("$@" 2>&1); then
    pass "$label: ${out##*$'\n'}"
  else
    fail "$label:"
    echo "$out"
  fi
}

# Each X.md (English) has its X.es.md (Spanish) with the same structure, links and code blocks,
# and --community public fails if a file a public repo carries is missing (SECURITY, the code of
# conduct, the .github templates). nvim's README is NvChad's, protected and English only.
layer_check "check-docs" \
  node "$LAYER_DIR/tools/check-docs.mjs" . --community public \
  --exclude 30-editor/nvim/.config/nvim/README.md
# Comments, script output and test names stay in English. The checker lists its exemptions after
# the verdict; they are dropped here so the verdict is the line layer_check reports.
# shellcheck disable=SC2317 # Reached through layer_check, which shellcheck cannot follow.
check_comments() {
  local out code
  out=$(node "$LAYER_DIR/tools/check-comments.mjs" .)
  code=$?
  grep -v '^exempt:' <<<"$out"
  return "$code"
}
layer_check "check-comments" check_comments
# docs/tasks.md and docs/backlog.md keep the format the task panel reads.
layer_check "panel/check" node "$LAYER_DIR/panel/check.mjs" .
# install.sh and uninstall.sh against a throwaway HOME; the real one is never touched.
layer_check "test-install" env CLAUDE_LAYER_DIR="$LAYER_DIR" tools/test-install.sh

if have gitleaks; then
  if gitleaks git --no-banner --redact --log-level warn .; then
    pass "gitleaks: no secrets in the whole history"
  else
    fail "gitleaks found possible secrets (details above)"
  fi
else
  skip "gitleaks not installed (CI runs it on every push)"
fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}All checks passed.${NC}"
else
  echo -e "${RED}Some checks failed.${NC}"
fi
exit "$FAILED"
