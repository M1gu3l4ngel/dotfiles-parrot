#!/usr/bin/env bash
# tools/check.sh
# Comprobaciones de calidad y seguridad del repo. Las mismas que ejecuta el CI
# (.github/workflows/ci.yml) en cada push, para poder correrlas en local antes
# de commitear:
#
#   ./tools/check.sh
#
# Qué comprueba:
#   1. Sintaxis de todos los scripts de shell (bash -n / sh -n)
#   2. shellcheck sobre esos scripts (bugs típicos: variables sin comillas,
#      bashismos en sh, como el $UID que rompía launch.sh) y formato con shfmt
#   3. Sintaxis de .zshrc (zsh -n)
#   4. Sintaxis de la config Lua de Neovim
#   5. JSON válido (tema de oh-my-posh, lazy-lock)
#   6. sudoers y keymap XKB (se validan con visudo y xkbcomp)
#   7. Higiene del repo público: sin binarios de fuentes ni rutas /home/<usuario>
#   8. Secretos en todo el historial con gitleaks (si está instalado)
#
# Una herramienta que falte se avisa y se omite (en local); el CI instala todas.
# Sale con código distinto de 0 si alguna comprobación falla.

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

# ----- ARCHIVOS A REVISAR -----
# Scripts de shell detectados por su shebang (no por extensión: bspwmrc y los
# scripts de polybar no tienen .sh). zsh se excluye: shellcheck no lo soporta.
SH_SCRIPTS=()
BASH_SCRIPTS=()
while IFS= read -r file; do
  # `read` en vez de `$(head -n1 ...)`: con archivos binarios (imágenes,
  # fuentes) la sustitución de comandos avisa de bytes nulos.
  first=""
  IFS= read -r first <"$file" 2>/dev/null
  case "$first" in
    '#!'*bash*) BASH_SCRIPTS+=("$file") ;;
    # dash es el /bin/sh de Debian: POSIX, se valida igual que sh.
    '#!'*/sh | '#!'*'env sh' | '#!'*dash*) SH_SCRIPTS+=("$file") ;;
    *) ;; # Resto de archivos: no son scripts de shell.
  esac
done < <(git ls-files)

# ----- 1. SINTAXIS DE SHELL -----
errors=0
for f in "${BASH_SCRIPTS[@]}"; do
  if ! bash -n "$f"; then
    fail "sintaxis bash: $f"
    errors=1
  fi
done
for f in "${SH_SCRIPTS[@]}"; do
  if ! sh -n "$f"; then
    fail "sintaxis sh: $f"
    errors=1
  fi
done
[ "$errors" -eq 0 ] && pass "Sintaxis de $((${#BASH_SCRIPTS[@]} + ${#SH_SCRIPTS[@]})) scripts de shell"

# ----- 2. SHELLCHECK -----
if have shellcheck; then
  if shellcheck "${BASH_SCRIPTS[@]}" "${SH_SCRIPTS[@]}"; then
    pass "shellcheck sin avisos"
  else
    fail "shellcheck encontró problemas (detalle arriba)"
  fi
else
  skip "shellcheck no instalado (apt install shellcheck)"
fi

# ----- 2b. FORMATO (SHFMT) -----
# Mismas opciones que usa Neovim al formatear (nvim/.../configs/conform.lua):
# 2 espacios e indentación de los `case`. -d muestra la diferencia sin tocar
# nada; para aplicar el formato: shfmt -i 2 -ci -w <archivo>.
if have shfmt; then
  if shfmt -i 2 -ci -d "${BASH_SCRIPTS[@]}" "${SH_SCRIPTS[@]}"; then
    pass "Formato shfmt correcto"
  else
    fail "Scripts sin formatear (diferencias arriba; aplicar con shfmt -i 2 -ci -w)"
  fi
else
  skip "shfmt no instalado (apt install shfmt)"
fi

# ----- 3. ZSH -----
if have zsh; then
  if zsh -n zsh/.zshrc; then pass "Sintaxis de zsh/.zshrc"; else fail "sintaxis zsh: zsh/.zshrc"; fi
else
  skip "zsh no instalado"
fi

# ----- 4. LUA (NEOVIM) -----
mapfile -t LUA_FILES < <(git ls-files '*.lua')
LUAC=""
for c in luac5.1 luac; do have "$c" && {
  LUAC=$c
  break
}; done
errors=0
if [ -n "$LUAC" ]; then
  for f in "${LUA_FILES[@]}"; do "$LUAC" -p "$f" || {
    fail "sintaxis Lua: $f"
    errors=1
  }; done
  [ "$errors" -eq 0 ] && pass "Sintaxis de ${#LUA_FILES[@]} archivos Lua ($LUAC)"
elif have nvim; then
  # Sin luac, el propio Neovim (LuaJIT) compila cada archivo sin ejecutarlo.
  for f in "${LUA_FILES[@]}"; do
    out=$(nvim --headless -u NONE -c "lua local ok, err = loadfile('$f'); if not ok then io.stderr:write(err) end" -c 'qa!' 2>&1)
    [ -n "$out" ] && {
      fail "sintaxis Lua: $out"
      errors=1
    }
  done
  [ "$errors" -eq 0 ] && pass "Sintaxis de ${#LUA_FILES[@]} archivos Lua (nvim)"
else
  skip "ni luac ni nvim instalados: se omite Lua"
fi

# ----- 5. JSON -----
errors=0
while IFS= read -r f; do
  python3 -m json.tool "$f" >/dev/null 2>&1 || {
    fail "JSON inválido: $f"
    errors=1
  }
done < <(git ls-files '*.json')
[ "$errors" -eq 0 ] && pass "JSON válido"

# ----- 6. SUDOERS Y XKB -----
if have visudo || [ -x /usr/sbin/visudo ]; then
  tmp=$(mktemp)
  sed 's/__USER__/root/g' system/sudoers.d/anon_toggle >"$tmp"
  if PATH="$PATH:/usr/sbin" visudo -c -q -f "$tmp"; then pass "Regla sudoers válida"; else fail "sudoers inválido: system/sudoers.d/anon_toggle"; fi
  rm -f "$tmp"
else
  skip "visudo no disponible"
fi
if have xkbcomp; then
  tmp=$(mktemp)
  if xkbcomp -w 0 -I"xkb/.config/xkb" xkb/.config/xkb/keymap.xkb "$tmp" 2>/dev/null; then
    pass "Keymap XKB compila"
  else
    fail "keymap XKB no compila: xkb/.config/xkb/keymap.xkb"
  fi
  rm -f "$tmp"
else
  skip "xkbcomp no instalado (apt install x11-xkb-utils)"
fi

# ----- 7. HIGIENE DEL REPO PÚBLICO -----
# Fuentes: se instalan con bootstrap.sh; versionarlas infla el repo y trae
# problemas de licencia.
fonts=$(git ls-files '*.ttf' '*.otf')
if [ -z "$fonts" ]; then pass "Sin binarios de fuentes versionados"; else fail "Fuentes versionadas: $fonts"; fi
# Rutas absolutas a un home concreto: filtran el nombre de usuario y rompen el
# repo en otras máquinas (usar $HOME o ~).
paths=$(git grep -nIE '/home/[a-z_][a-z0-9_-]*/' || true)
if [ -z "$paths" ]; then pass "Sin rutas /home/<usuario> hardcodeadas"; else
  fail "Rutas de home hardcodeadas:"
  echo "$paths"
fi

# ----- 8. SECRETOS -----
if have gitleaks; then
  if gitleaks git --no-banner --redact --log-level warn .; then
    pass "gitleaks: sin secretos en todo el historial"
  else
    fail "gitleaks encontró posibles secretos (detalle arriba)"
  fi
else
  skip "gitleaks no instalado (el CI lo ejecuta en cada push)"
fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}Todas las comprobaciones pasaron.${NC}"
else
  echo -e "${RED}Hay comprobaciones fallidas.${NC}"
fi
exit "$FAILED"
