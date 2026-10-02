#!/usr/bin/env bash
# lib/links.sh
# Mapeo de enlaces del repo: qué archivo o carpeta del repo se enlaza en qué
# ruta de $HOME. Lo cargan install.sh (crea los enlaces) y uninstall.sh (los
# quita y restaura las copias), así la lista vive en un solo sitio y los dos
# scripts no pueden desincronizarse.
#
# No se ejecuta: se carga con `. lib/links.sh` y requiere DOTFILES_DIR
# definido antes. Formato de cada entrada: "origen|destino".
# Para añadir una config nueva, basta con sumar una línea aquí.

# shellcheck disable=SC2034 # LINKS se usa en los scripts que cargan este archivo.
LINKS=(
  "$DOTFILES_DIR/bspwm/.config/bspwm/bspwmrc|$HOME/.config/bspwm/bspwmrc"
  "$DOTFILES_DIR/bspwm/.config/bspwm/scripts|$HOME/.config/bspwm/scripts"
  "$DOTFILES_DIR/sxhkd/.config/sxhkd/sxhkdrc|$HOME/.config/sxhkd/sxhkdrc"
  "$DOTFILES_DIR/kitty/.config/kitty|$HOME/.config/kitty"
  "$DOTFILES_DIR/picom/.config/picom|$HOME/.config/picom"
  "$DOTFILES_DIR/polybar/.config/polybar|$HOME/.config/polybar"
  "$DOTFILES_DIR/rofi/.config/rofi|$HOME/.config/rofi"
  "$DOTFILES_DIR/dunst/.config/dunst|$HOME/.config/dunst"
  "$DOTFILES_DIR/xkb/.config/xkb|$HOME/.config/xkb"
  # Archivo a archivo, no ~/.config/gtk-4.0 entero: ahí guardan su estado
  # otras apps.
  "$DOTFILES_DIR/gtk/.config/gtk-4.0/gtk.css|$HOME/.config/gtk-4.0/gtk.css"
  "$DOTFILES_DIR/gtk/.config/gtk-4.0/settings.ini|$HOME/.config/gtk-4.0/settings.ini"
  # VSCodium de Parrot lee sus ajustes de "Visual Studio Code", no de VSCodium.
  "$DOTFILES_DIR/vscodium/settings.json|$HOME/.config/Visual Studio Code/User/settings.json"
  # Solo el archivo, no ~/.gnupg entero: ese directorio contiene las claves
  # privadas y debe ser real, con permisos 700 y fuera de cualquier repo
  # (install.sh lo crea así antes de enlazar).
  "$DOTFILES_DIR/gnupg/.gnupg/gpg-agent.conf|$HOME/.gnupg/gpg-agent.conf"
  "$DOTFILES_DIR/nvim/.config/nvim|$HOME/.config/nvim"
  "$DOTFILES_DIR/scripts/.config/scripts|$HOME/.config/scripts"
  "$DOTFILES_DIR/zsh/.zshrc|$HOME/.zshrc"
  # Capa global de Claude Code (ver claude/README.md). Archivo a archivo: el
  # resto de ~/.claude es estado local (sesiones, memoria, settings.json).
  "$DOTFILES_DIR/claude/CLAUDE.md|$HOME/.claude/CLAUDE.md"
  "$DOTFILES_DIR/claude/statusline.mjs|$HOME/.claude/statusline.mjs"
  "$DOTFILES_DIR/claude/hooks/block-shell-edits.mjs|$HOME/.claude/hooks/block-shell-edits.mjs"
)
