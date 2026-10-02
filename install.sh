#!/usr/bin/env bash
# install.sh (en la raíz del repo)
# Instalador idempotente de los dotfiles.
#
# Crea symlinks desde este repositorio hacia las rutas reales en $HOME
# (~/.config/bspwm/bspwmrc, ~/.zshrc, etc.), según la lista de lib/links.sh.
# Antes de crear cada enlace hace backup de cualquier archivo existente con el
# sufijo .pre-dotfiles.bak para no perder configuración previa.
# Para revertirlo: ./uninstall.sh (con --dry-run para ver antes qué haría).
#
# Es idempotente: si ya existe el symlink correcto no hace nada, así que
# se puede ejecutar varias veces sin romper el sistema.
#
# Uso: ./install.sh

# ----- MODO ESTRICTO -----
# -e  aborta si cualquier comando falla
# -u  aborta si se usa una variable no definida (atrapa typos)
# -o pipefail  hace que un pipe falle si cualquier etapa falla, no solo la última
set -euo pipefail

# ----- CONFIGURACIÓN -----
# Directorio donde vive este repo: el del propio script, sin suponer que se
# clonó en ~/dotfiles. Con una ruta fija, un clon en otra carpeta crearía
# enlaces hacia un directorio inexistente y rompería todo el escritorio.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Sufijo que se añade a los archivos respaldados para distinguirlos del original.
BACKUP_SUFFIX=".pre-dotfiles.bak"

# ----- MENSAJES -----
# Mismo estilo que bootstrap.sh. Solo se informa de lo que cambia; lo que ya
# estaba bien se resume en una línea al final, para que un error o un backup
# no se pierdan entre mensajes de "ya enlazado".
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

# Contadores para el resumen final.
LINKED=0
ALREADY=0

# ----- LÓGICA DE BACKUP -----
# Decide qué hacer con el archivo que está en la ruta destino antes de
# crear el symlink nuevo. Devuelve 0 si la ruta quedó libre para enlazar,
# o 1 si ya estaba enlazada al lugar correcto y no hay nada que hacer.
backup_if_exists() {
  local target="$1"
  # Symlink a este repo: ya está instalado, no hay nada que hacer.
  if [ -L "$target" ] && [[ "$(readlink "$target")" == "$DOTFILES_DIR"* ]]; then
    ALREADY=$((ALREADY + 1))
    return 1
  fi
  # Cualquier otra cosa (archivo, carpeta o un enlace propio a otro sitio) se
  # mueve a .bak para no perderla: uninstall.sh la devuelve a su sitio. -L
  # cubre también los enlaces rotos, que -e no detecta.
  if [ -e "$target" ] || [ -L "$target" ]; then
    # Si ya hay un .bak de una ejecución anterior, se añade la fecha en vez de
    # sobrescribirlo: esa copia puede ser la única de la config original.
    local backup="${target}${BACKUP_SUFFIX}"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      backup="${backup}.$(date +%Y%m%d%H%M%S)"
    fi
    local detail=""
    [ -L "$target" ] && detail=" (enlace a $(readlink "$target"))"
    warn "Copia de seguridad: $(short "$target")$detail -> $(short "$backup")"
    mv "$target" "$backup"
  fi
  return 0
}

# ----- CREACIÓN DE SYMLINKS -----
# Crea el enlace simbólico del repo al sistema, asegurándose primero de que
# el directorio padre exista (por ejemplo ~/.config/bspwm/).
create_symlink() {
  local source="$1"
  local target="$2"
  if backup_if_exists "$target"; then
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    ok "Enlazado: $(short "$target")"
    LINKED=$((LINKED + 1))
  fi
}

# ----- VALIDACIÓN PREVIA -----
# Si el script se copió fuera del repo, los archivos fuente no existen: mejor
# fallar temprano con un mensaje claro que generar enlaces rotos.
if [ ! -f "$DOTFILES_DIR/zsh/.zshrc" ] || [ ! -f "$DOTFILES_DIR/lib/links.sh" ]; then
  die "install.sh debe ejecutarse dentro del repo (no existe $DOTFILES_DIR/lib/links.sh)"
fi

# ----- SYMLINKS: origen -> destino -----
# La lista está en lib/links.sh, compartida con uninstall.sh. Para añadir una
# config nueva, se suma una línea allí, no aquí.
# shellcheck source=lib/links.sh
. "$DOTFILES_DIR/lib/links.sh"

# ~/.gnupg se crea antes que su enlace (gpg-agent.conf) porque create_symlink
# lo crearía con los permisos por defecto (755), y gpg avisa de "unsafe
# permissions" con un homedir abierto.
mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"

for link in "${LINKS[@]}"; do
  create_symlink "${link%%|*}" "${link#*|}"
done

# ----- WALLPAPER (NO SOBRESCRIBE SI YA EXISTE UNO) -----
# bspwmrc carga ~/.config/wallpaper.jpg al iniciar. Aquí lo enlazamos al
# default del repo SOLO si el usuario no tiene ya un wallpaper propio: así
# `./install.sh` no pisa fondos personales en una segunda corrida.
if [ ! -e "$HOME/.config/wallpaper.jpg" ]; then
  mkdir -p "$HOME/.config"
  ln -s "$DOTFILES_DIR/assets/wallpaper.jpg" "$HOME/.config/wallpaper.jpg"
  ok "Fondo de pantalla por defecto: ~/.config/wallpaper.jpg"
  LINKED=$((LINKED + 1))
fi

# ----- ARCHIVOS DE ESTADO INICIALES -----
# settarget/cleartarget (definidos en .zshrc) y el módulo target_module de
# polybar escriben/leen ~/.config/bin/target. Lo creamos vacío en la primera
# instalación para que el script victim_to_hack.sh no falle al arrancar
# polybar antes de que el usuario haya corrido `settarget` nunca.
mkdir -p "$HOME/.config/bin"
if [ ! -f "$HOME/.config/bin/target" ]; then
  : >"$HOME/.config/bin/target"
fi

# ----- SETTINGS DE CLAUDE CODE (SOLO SI NO EXISTE) -----
# Se copia de la plantilla, no se enlaza: tiene rutas con el usuario y Claude
# Code le añade datos propios de la máquina (autoMode, plugins). Si ya existe
# no se toca, para no pisar esos datos; lo que falte se fusiona a mano (ver
# claude/README.md). La plantilla no registra la barra de estado: se añade
# aquí con jq, con la ruta real.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ ! -e "$CLAUDE_SETTINGS" ] && command -v jq >/dev/null; then
  template=$(<"$DOTFILES_DIR/claude/settings.template.json")
  mkdir -p "$HOME/.claude"
  printf '%s\n' "${template//REEMPLAZA_RUTA_HOME/$HOME}" |
    jq --arg cmd "node $HOME/.claude/statusline.mjs" \
      '. + {statusLine: {type: "command", command: $cmd}}' >"$CLAUDE_SETTINGS"
  chmod 600 "$CLAUDE_SETTINGS"
  ok "Settings de Claude Code creados: $(short "$CLAUDE_SETTINGS")"
fi

# ----- MODO OSCURO EN APPS GTK4 -----
# libadwaita (Nautilus) toma el modo oscuro de esta preferencia del sistema;
# sin ella abre en claro aunque el resto del escritorio sea oscuro. Se guarda
# en dconf, no en un archivo que se pueda enlazar.
if command -v gsettings >/dev/null &&
  [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" != "'prefer-dark'" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  ok "Modo oscuro activado para las apps GTK4"
fi

# ----- GESTOR DE ARCHIVOS POR DEFECTO -----
# Las apps que abren una carpeta (p. ej. "Mostrar en carpeta" de Firefox) usan
# la asociación de inode/directory. Sin esto la tomaba un editor de código.
FOLDER_APP="org.gnome.Nautilus.desktop"
if command -v xdg-mime >/dev/null && [ -f "/usr/share/applications/$FOLDER_APP" ] &&
  [ "$(xdg-mime query default inode/directory)" != "$FOLDER_APP" ]; then
  xdg-mime default "$FOLDER_APP" inode/directory
  ok "Carpetas asociadas al gestor de archivos (Nautilus)"
fi

# ----- INDEXADOR DE ARCHIVOS DESACTIVADO -----
# Nautilus instala localsearch, que recorre todos los archivos en segundo
# plano (CPU y disco constantes) para acelerar las búsquedas. `mask` impide
# que arranque aunque Nautilus lo pida; la búsqueda sigue funcionando
# recorriendo las carpetas en el momento.
if command -v systemctl >/dev/null &&
  [ "$(systemctl --user is-enabled localsearch-3.service 2>/dev/null)" != "masked" ]; then
  systemctl --user mask --now localsearch-3.service >/dev/null 2>&1 &&
    ok "Indexador de archivos (localsearch) desactivado"
fi

# ----- RESUMEN -----
if [ "$LINKED" -eq 0 ]; then
  ok "Las $ALREADY configuraciones ya estaban enlazadas"
else
  ok "$LINKED enlaces nuevos, $ALREADY ya estaban bien"
  echo "    Para aplicarlos: exec zsh en cada terminal y Super+Alt+R"
fi
