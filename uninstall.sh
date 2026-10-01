#!/usr/bin/env bash
# uninstall.sh (en la raíz del repo)
# Revierte install.sh: quita los enlaces que apuntan a este repo y restaura la
# copia .pre-dotfiles.bak que install.sh guardó de cada archivo original.
#
# Solo toca enlaces de este repo: un archivo real o un enlace a otro sitio se
# deja como está. No desinstala paquetes de apt, no revierte el hardening de
# system/setup.sh ni los ajustes que install.sh aplica sin enlaces (modo oscuro
# de GTK4, gestor de archivos por defecto, indexador desactivado).
#
# Es idempotente: una segunda ejecución no encuentra nada que quitar.
#
# Uso:
#   ./uninstall.sh --dry-run   muestra qué haría, sin tocar nada
#   ./uninstall.sh             lo aplica
#   ./uninstall.sh --help      esta ayuda

set -euo pipefail

# ----- CONFIGURACIÓN -----
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Mismo sufijo que usa install.sh al respaldar.
BACKUP_SUFFIX=".pre-dotfiles.bak"

# ----- MENSAJES -----
# Mismo estilo que install.sh y bootstrap.sh.
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
# Rutas con ~ en vez del home completo: más cortas y sin el nombre de usuario.
short() { echo "${1/#"$HOME"/\~}"; }

usage() {
  sed -n '2,/^$/{s/^# \{0,1\}//;p}' "${BASH_SOURCE[0]}"
  exit 0
}

# ----- ARGUMENTOS -----
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h | --help) usage ;;
    *) die "Opción desconocida: $arg (ver --help)" ;;
  esac
done

if [ ! -f "$DOTFILES_DIR/lib/links.sh" ]; then
  die "uninstall.sh debe ejecutarse dentro del repo (no existe $DOTFILES_DIR/lib/links.sh)"
fi

# ----- DESTINOS -----
# Los mismos que crea install.sh, de la lista compartida.
# shellcheck source=lib/links.sh
. "$DOTFILES_DIR/lib/links.sh"
TARGETS=()
for link in "${LINKS[@]}"; do
  TARGETS+=("${link#*|}")
done
# El fondo no está en la lista porque install.sh solo lo enlaza si no hay uno
# propio; si el enlace es del repo, también se quita.
TARGETS+=("$HOME/.config/wallpaper.jpg")

# Contadores para el resumen final.
REMOVED=0
RESTORED=0

# En --dry-run, `act` solo describe; si no, ejecuta el comando.
act() {
  [ "$DRY_RUN" -eq 1 ] || "$@"
}

# ----- RESTAURAR LA COPIA -----
# Devuelve el original a su sitio. Solo la copia sin fecha: es la que guardó
# la primera instalación. Las copias con fecha (de reinstalaciones) se dejan
# para revisarlas a mano, porque no se sabe cuál es la buena.
restore_backup() {
  local target="$1" backup="$1$BACKUP_SUFFIX"
  if [ -e "$backup" ] || [ -L "$backup" ]; then
    act mv -- "$backup" "$target"
    ok "$([ "$DRY_RUN" -eq 1 ] && echo "Restauraría" || echo "Restaurado"): $(short "$target")"
    RESTORED=$((RESTORED + 1))
  fi
  local extra
  for extra in "$backup".*; do
    if [ -e "$extra" ] || [ -L "$extra" ]; then
      warn "Copia con fecha sin restaurar (revísala a mano): $(short "$extra")"
    fi
  done
  return 0
}

# ----- QUITAR UN ENLACE -----
unlink_target() {
  local target="$1"
  if [ -L "$target" ] && [[ "$(readlink "$target")" == "$DOTFILES_DIR"* ]]; then
    act rm -- "$target"
    ok "$([ "$DRY_RUN" -eq 1 ] && echo "Quitaría el enlace" || echo "Enlace quitado"): $(short "$target")"
    REMOVED=$((REMOVED + 1))
    restore_backup "$target"
  elif [ -e "$target" ] || [ -L "$target" ]; then
    # Archivo real o enlace a otro sitio: no es de este repo, no se toca.
    warn "No es un enlace de este repo, se deja: $(short "$target")"
  else
    # Sin nada en el destino (p. ej. una desinstalación interrumpida): si
    # queda la copia, se restaura igualmente.
    restore_backup "$target"
  fi
}

[ "$DRY_RUN" -eq 1 ] && echo "    Simulación (--dry-run): no se modifica nada."
for target in "${TARGETS[@]}"; do
  unlink_target "$target"
done

# ----- RESUMEN -----
if [ "$DRY_RUN" -eq 1 ]; then
  ok "Se quitarían $REMOVED enlaces y se restaurarían $RESTORED copias"
  echo "    Para aplicarlo: ./uninstall.sh"
elif [ "$REMOVED" -eq 0 ] && [ "$RESTORED" -eq 0 ]; then
  ok "No había enlaces de este repo que quitar"
else
  ok "$REMOVED enlaces quitados, $RESTORED copias restauradas"
  echo "    Cierra sesión y vuelve a entrar para aplicar la configuración original"
fi
