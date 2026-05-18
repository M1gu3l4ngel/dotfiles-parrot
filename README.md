# 🦜 dotfiles — bytebit

  Configuraciones personales de Linux (Parrot OS) versionadas con git.

  Setup pro completo: bspwm + sxhkd + polybar + picom + rofi + kitty + zsh + Powerlevel10k + NvChad.

  ---

  ## 📦 Componentes incluidos

  | Componente | Ruta original | Descripción |
  |---|---|---|
  | **bspwm** | `~/.config/bspwm/bspwmrc` | Window manager (Binary Space Partitioning) |
  | **sxhkd** | `~/.config/sxhkd/sxhkdrc` | Atajos de teclado |
  | **kitty** | `~/.config/kitty/` | Terminal emulator (GPU accelerated) |
  | **picom** | `~/.config/picom/` | Compositor (sombras, transparencias) |
  | **polybar** | `~/.config/polybar/` | Barra de estado |
  | **rofi** | `~/.config/rofi/` | Application launcher |
  | **nvim** | `~/.config/nvim/` | NvChad (Neovim framework) |
  | **scripts** | `~/.config/scripts/` | Scripts personalizados (target, vpn, ethernet) |
  | **zsh** | `~/.zshrc`, `~/.p10k.zsh` | Shell + Powerlevel10k prompt |

  ---

  ## 🚀 Instalación en máquina nueva

  ```bash
  git clone https://github.com/USER/dotfiles.git ~/dotfiles
  cd ~/dotfiles
  ./install.sh

  El script install.sh es idempotente: puede correrse N veces. Hace backup automático de cualquier archivo existente con sufijo .pre-dotfiles.bak.

  ---
  🔧 Dependencias

  Paquetes necesarios

  sudo apt install -y bspwm sxhkd kitty picom polybar rofi neovim zsh dunst feh

  Herramientas opcionales

  sudo apt install -y bat lsd fzf

  Fuentes

  Hack Nerd Font (requerida para íconos en Polybar y Powerlevel10k):

  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  curl -fLo "Hack.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  unzip Hack.zip && rm Hack.zip
  fc-cache -fv

  Powerlevel10k

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

  ---
  📚 Documentación

  Ver docs/ para notas detalladas por componente (cuando estén creadas).

  ---
  🔄 Workflow

  Hacer un cambio

  1. Editar el archivo en su ruta normal (ej: nvim ~/.config/bspwm/bspwmrc)
  2. Los cambios se aplican al archivo real en ~/dotfiles/... (vía symlink)
  3. cd ~/dotfiles && git status para ver qué cambió
  4. git diff para revisar cambios
  5. git add -A && git commit -m "feat(bspwm): descripcion" cuando estés feliz

  Sincronizar con remote

  cd ~/dotfiles
  git push    # subir cambios
  git pull    # bajar cambios desde otra máquina

  ---
  Mantenido por bytebit · Estado: vivo
