#!/usr/bin/env bash
# install.sh (en la raíz del repo)
# Instalador idempotente de los dotfiles.
#
# Crea symlinks desde este repositorio hacia las rutas reales en $HOME
# (~/.config/bspwm/bspwmrc, ~/.zshrc, etc.). Antes de crear cada enlace
# hace backup de cualquier archivo existente con el sufijo .pre-dotfiles.bak
# para no perder configuración previa.
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
  if [ -L "$target" ]; then
    # Ya hay un symlink: revisamos si apunta a este repo o a otro lugar.
    local link_target
    link_target=$(readlink "$target")
    if [[ "$link_target" == "$DOTFILES_DIR"* ]]; then
      # Apunta a nuestro repo, todo correcto. No tocamos nada.
      ALREADY=$((ALREADY + 1))
      return 1
    fi
    # Symlink apunta a otro lado (instalación vieja, otro repo): lo eliminamos.
    warn "Enlace antiguo reemplazado: $(short "$target") (apuntaba a $link_target)"
    rm "$target"
  elif [ -e "$target" ]; then
    # Existe un archivo real (no symlink): lo movemos a .bak para no perderlo.
    # Si ya hay un .bak de una ejecución anterior, se añade la fecha en vez de
    # sobrescribirlo: esa copia puede ser la única de la config original.
    local backup="${target}${BACKUP_SUFFIX}"
    if [ -e "$backup" ]; then
      backup="${backup}.$(date +%Y%m%d%H%M%S)"
    fi
    warn "Copia de seguridad: $(short "$target") -> $(short "$backup")"
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
if [ ! -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  die "install.sh debe ejecutarse dentro del repo (no existe $DOTFILES_DIR/zsh/.zshrc)"
fi

# ----- SYMLINKS: source -> target -----
# Cada línea define un archivo o carpeta del repo y dónde debe vivir en $HOME.
# Si quieres añadir una config nueva, basta con sumar otra línea aquí.
create_symlink "$DOTFILES_DIR/bspwm/.config/bspwm/bspwmrc" "$HOME/.config/bspwm/bspwmrc"
create_symlink "$DOTFILES_DIR/bspwm/.config/bspwm/scripts" "$HOME/.config/bspwm/scripts"
create_symlink "$DOTFILES_DIR/sxhkd/.config/sxhkd/sxhkdrc" "$HOME/.config/sxhkd/sxhkdrc"
create_symlink "$DOTFILES_DIR/kitty/.config/kitty" "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/picom/.config/picom" "$HOME/.config/picom"
create_symlink "$DOTFILES_DIR/polybar/.config/polybar" "$HOME/.config/polybar"
create_symlink "$DOTFILES_DIR/rofi/.config/rofi" "$HOME/.config/rofi"
create_symlink "$DOTFILES_DIR/dunst/.config/dunst" "$HOME/.config/dunst"
create_symlink "$DOTFILES_DIR/xkb/.config/xkb" "$HOME/.config/xkb"
# Archivo a archivo, no ~/.config/gtk-4.0 entero: ahí guardan su estado otras
# apps.
create_symlink "$DOTFILES_DIR/gtk/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
create_symlink "$DOTFILES_DIR/gtk/.config/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
# Solo el archivo, no ~/.gnupg entero: ese directorio contiene las claves
# privadas y debe ser real, con permisos 700 y fuera de cualquier repo.
# Se crea antes que el enlace porque create_symlink usaría los permisos por
# defecto (755) y gpg avisa de "unsafe permissions" con un homedir abierto.
mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
create_symlink "$DOTFILES_DIR/gnupg/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
create_symlink "$DOTFILES_DIR/nvim/.config/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/scripts/.config/scripts" "$HOME/.config/scripts"
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

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
