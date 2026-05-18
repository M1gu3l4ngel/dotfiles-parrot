#!/usr/bin/env bash
  # install.sh - Idempotent dotfiles installer
  # Repository: ~/dotfiles
  # Usage: ./install.sh
  #
  # Crea symlinks desde el repo hacia las ubicaciones correctas.
  # Hace backup automatico de archivos existentes con sufijo .pre-dotfiles.bak
  # Es idempotente: corre N veces sin romper nada.

  set -euo pipefail

  DOTFILES_DIR="${HOME}/dotfiles"
  BACKUP_SUFFIX=".pre-dotfiles.bak"

  # Colores
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  NC='\033[0m'

  log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
  log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
  log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
  log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

  backup_if_exists() {
      local target="$1"
      if [ -L "$target" ]; then
          local link_target
          link_target=$(readlink "$target")
          if [[ "$link_target" == "$DOTFILES_DIR"* ]]; then
              log_info "Already linked: $target"
              return 1
          fi
          log_warn "Removing wrong symlink: $target"
          rm "$target"
      elif [ -e "$target" ]; then
          log_warn "Backing up: $target -> ${target}${BACKUP_SUFFIX}"
          mv "$target" "${target}${BACKUP_SUFFIX}"
      fi
      return 0
  }

  create_symlink() {
      local source="$1"
      local target="$2"
      if backup_if_exists "$target"; then
          mkdir -p "$(dirname "$target")"
          ln -s "$source" "$target"
          log_ok "Linked: $target"
      fi
  }

  if [ ! -d "$DOTFILES_DIR" ]; then
      log_error "Dotfiles directory not found: $DOTFILES_DIR"
      exit 1
  fi

  log_info "Starting dotfiles installation..."
  log_info "Source: $DOTFILES_DIR"

  # Symlinks: source -> target
  create_symlink "$DOTFILES_DIR/bspwm/.config/bspwm/bspwmrc" "$HOME/.config/bspwm/bspwmrc"
  create_symlink "$DOTFILES_DIR/sxhkd/.config/sxhkd/sxhkdrc" "$HOME/.config/sxhkd/sxhkdrc"
  create_symlink "$DOTFILES_DIR/kitty/.config/kitty"        "$HOME/.config/kitty"
  create_symlink "$DOTFILES_DIR/picom/.config/picom"        "$HOME/.config/picom"
  create_symlink "$DOTFILES_DIR/polybar/.config/polybar"    "$HOME/.config/polybar"
  create_symlink "$DOTFILES_DIR/rofi/.config/rofi"          "$HOME/.config/rofi"
  create_symlink "$DOTFILES_DIR/nvim/.config/nvim"          "$HOME/.config/nvim"
  create_symlink "$DOTFILES_DIR/scripts/.config/scripts"    "$HOME/.config/scripts"
  create_symlink "$DOTFILES_DIR/zsh/.zshrc"                 "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh"              "$HOME/.p10k.zsh"

  log_ok "Installation complete!"
  log_info "Reload your shell:  exec zsh"
  log_info "Reload bspwm:       Super+Alt+R"
