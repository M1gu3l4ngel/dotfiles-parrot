# 🦜 dotfiles

Configuración personal de Parrot Security con bspwm + polybar + kitty + zsh.
Pensado para pentesting, rice limpio y productividad en VM.

---

## ✨ Stack

| Componente | Para qué sirve |
|---|---|
| **bspwm** | Tiling window manager |
| **sxhkd** | Atajos de teclado |
| **polybar** | Barra de estado |
| **picom** | Compositor (sombras, transparencia) |
| **rofi** | Lanzador de aplicaciones |
| **kitty** | Emulador de terminal |
| **zsh + Powerlevel10k** | Shell + prompt |
| **NvChad** | Distribución de Neovim |
| **feh** | Wallpaper |
| **dunst** | Notificaciones |

---

## 📋 Pre-requisitos

Antes de instalar, necesitas tener funcionando:

- Parrot Security (probado en 7.2)
- Los paquetes del stack ya instalados (...)
- `git` y `stow` (opcional pero recomendado)

Antes de aplicar los dotfiles necesitas tener el stack instalado:

### 1. Paquetes del sistema (apt)

    sudo apt update && sudo apt install -y bspwm sxhkd polybar picom rofi kitty zsh feh dunst bat lsd tmux zsh-autosuggestions zsh-syntax-highlighting git stow

### 2. Neovim (binario oficial, NO el de apt)

Primero quitamos el viejo del sistema:

    sudo apt purge -y neovim

Luego instalamos el binario oficial:

    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

### 3. Plugins y temas (desde GitHub)

    # Powerlevel10k (tema zsh)
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

    # NvChad (config de Neovim)
    git clone --depth 1 https://github.com/NvChad/NvChad ~/.config/nvim

    # fzf (fuzzy finder)
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

### 4. Hack Nerd Font

Descarga desde [nerdfonts.com](https://www.nerdfonts.com/) → opción "Hack Nerd Fonts". O directo por consola:

    wget -P /tmp https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    sudo unzip -o /tmp/Hack.zip -d /usr/local/share/fonts/
    sudo fc-cache -fv

---

## 🚀 Paso 1 — Clonar el repo

  git clone https://github.com/M1gu3l4ngel/dotfiles-parrot.git ~/dotfiles
  cd ~/dotfiles

---

## 🚀 Paso 2 — Ejecutar el instalador

  ./install.sh

El script:
- Crea backup de tus configs actuales (`.pre-dotfiles.bak`)
- Crea symlinks desde `~/.config/` y `~` hacia los archivos del repo

---

## 🚀 Paso 3 — Aplicar zsh

  chsh -s $(which zsh)

Cierra sesión y vuelve a entrar.

---

## 🚀 Paso 4 — Reload de bspwm/polybar

Dentro de bspwm:

- `Super + Shift + R` → recargar polybar
- `Super + Escape` → recargar sxhkd

---

## 🔑 SSH (opcional, recomendado)

Para no escribir la passphrase en cada terminal:

  sudo apt install keychain -y

Ya está configurado en el `.zshrc`. Solo necesitas tener tu llave en `~/.ssh/id_ed25519`.

---

## 📂 Estructura

  dotfiles/
  ├── bspwm/        → ~/.config/bspwm/
  ├── sxhkd/        → ~/.config/sxhkd/
  ├── polybar/      → ~/.config/polybar/
  ├── picom/        → ~/.config/picom/
  ├── rofi/         → ~/.config/rofi/
  ├── kitty/        → ~/.config/kitty/
  ├── nvim/         → ~/.config/nvim/
  ├── scripts/      → ~/.config/scripts/
  ├── zsh/.zshrc    → ~/.zshrc
  ├── zsh/.p10k.zsh → ~/.p10k.zsh
  └── install.sh

---

## 🛠 Personalizar

Edita los archivos en `~/dotfiles/` — los symlinks hacen que los cambios se apliquen inmediatamente al recargar el componente correspondiente.

---

## 🙏 Créditos

Este setup está basado en el curso de personalización de Linux de **[S4vitar](https://github.com/s4vitar)**. Las configuraciones de **bspwm**, **sxhkd**, **polybar** y **picom** siguen su estilo y enfoque
pedagógico.

Adaptado por **M1gu3l4ng3l** para su flujo personal de pentesting.

---

## 📜 Licencia

[MIT](LICENSE) — usa, copia, modifica libremente.

---

Hecho con 🦜 por **[M1gu3l4ng3l](https://github.com/M1gu3l4ngel)**
