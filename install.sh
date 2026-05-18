#!/usr/bin/env bash
# ~/dotfiles/install.sh
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
# Directorio donde vive este repo. Todos los archivos fuente se buscan aquí.
DOTFILES_DIR="${HOME}/dotfiles"
# Sufijo que se añade a los archivos respaldados para distinguirlos del original.
BACKUP_SUFFIX=".pre-dotfiles.bak"

# ----- COLORES PARA LOGS -----
# Códigos ANSI para imprimir mensajes con color y leer el output más rápido.
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color: resetea el color al default de la terminal

# ----- HELPERS DE LOGGING -----
# Cada nivel tiene su color para que el output sea escaneable de un vistazo.
log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
      log_info "Already linked: $target"
      return 1
    fi
    # Symlink apunta a otro lado (instalación vieja, otro repo): lo eliminamos.
    log_warn "Removing wrong symlink: $target"
    rm "$target"
  elif [ -e "$target" ]; then
    # Existe un archivo real (no symlink): lo movemos a .bak para no perderlo.
    log_warn "Backing up: $target -> ${target}${BACKUP_SUFFIX}"
    mv "$target" "${target}${BACKUP_SUFFIX}"
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
    log_ok "Linked: $target"
  fi
}

# ----- VALIDACIÓN PREVIA -----
# Si alguien ejecuta el script desde un sistema sin el repo clonado en ~/dotfiles
# preferimos fallar temprano con un mensaje claro en vez de generar enlaces rotos.
if [ ! -d "$DOTFILES_DIR" ]; then
  log_error "Dotfiles directory not found: $DOTFILES_DIR"
  exit 1
fi

log_info "Starting dotfiles installation..."
log_info "Source: $DOTFILES_DIR"

# ----- SYMLINKS: source -> target -----
# Cada línea define un archivo o carpeta del repo y dónde debe vivir en $HOME.
# Si quieres añadir una config nueva, basta con sumar otra línea aquí.
create_symlink "$DOTFILES_DIR/bspwm/.config/bspwm/bspwmrc"  "$HOME/.config/bspwm/bspwmrc"
create_symlink "$DOTFILES_DIR/bspwm/.config/bspwm/scripts"  "$HOME/.config/bspwm/scripts"
create_symlink "$DOTFILES_DIR/sxhkd/.config/sxhkd/sxhkdrc"  "$HOME/.config/sxhkd/sxhkdrc"
create_symlink "$DOTFILES_DIR/kitty/.config/kitty"          "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/picom/.config/picom"          "$HOME/.config/picom"
create_symlink "$DOTFILES_DIR/polybar/.config/polybar"      "$HOME/.config/polybar"
create_symlink "$DOTFILES_DIR/rofi/.config/rofi"            "$HOME/.config/rofi"
create_symlink "$DOTFILES_DIR/nvim/.config/nvim"            "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/scripts/.config/scripts"      "$HOME/.config/scripts"
create_symlink "$DOTFILES_DIR/zsh/.zshrc"                   "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh"                "$HOME/.p10k.zsh"

# ----- WALLPAPER (NO SOBRESCRIBE SI YA EXISTE UNO) -----
# bspwmrc carga ~/.config/wallpaper.jpg al iniciar. Aquí lo enlazamos al
# default del repo SOLO si el usuario no tiene ya un wallpaper propio: así
# `./install.sh` no pisa fondos personales en una segunda corrida.
if [ ! -e "$HOME/.config/wallpaper.jpg" ]; then
  mkdir -p "$HOME/.config"
  ln -s "$DOTFILES_DIR/assets/wallpaper.jpg" "$HOME/.config/wallpaper.jpg"
  log_ok "Linked default wallpaper: $HOME/.config/wallpaper.jpg"
else
  log_info "Keeping existing wallpaper: $HOME/.config/wallpaper.jpg"
fi

# ----- ARCHIVOS DE ESTADO INICIALES -----
# settarget/cleartarget (definidos en .zshrc) y el módulo target_module de
# polybar escriben/leen ~/.config/bin/target. Lo creamos vacío en la primera
# instalación para que el script victim_to_hack.sh no falle al arrancar
# polybar antes de que el usuario haya corrido `settarget` nunca.
mkdir -p "$HOME/.config/bin"
if [ ! -f "$HOME/.config/bin/target" ]; then
  : > "$HOME/.config/bin/target"
  log_ok "Created empty target file: $HOME/.config/bin/target"
fi

# ----- FINAL -----
log_ok "Installation complete!"
log_info "Reload your shell:  exec zsh"
log_info "Reload bspwm:       Super+Alt+R"
