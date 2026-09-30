#!/usr/bin/env bash
# bootstrap.sh
# Instalación completa en un solo comando sobre Parrot OS recién instalado:
#
#   git clone https://github.com/M1gu3l4ngel/dotfiles-parrot.git ~/dotfiles
#   cd ~/dotfiles && ./bootstrap.sh
#
# Orden: paquetes de apt -> fuentes -> Neovim -> oh-my-posh -> nvm + Node +
# pnpm + Claude Code -> symlinks (install.sh) -> hardening (system/setup.sh)
# -> zsh como shell -> [Docker rootless, opcional] -> guía de GPG/SSH/pass.
#
# Idempotente: cada paso comprueba si ya está hecho (y en qué versión) y solo
# aplica lo que falta. Se puede volver a ejecutar tras un fallo o para
# actualizar una versión fijada.
#
# Se ejecuta como usuario normal: pide sudo una vez y lo usa solo en los pasos
# que tocan el sistema (apt, /opt, /etc).
#
# Uso:
#   ./bootstrap.sh                 instalación completa
#   ./bootstrap.sh --with-docker   además, Docker Engine en modo rootless
#   ./bootstrap.sh --help

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# VERSIONES FIJADAS
# =============================================================================
# Todo lo que no viene de apt se descarga en una versión concreta y se
# comprueba contra el SHA-256 guardado aquí. Si la descarga no coincide
# (corrupta o manipulada), la instalación se detiene. Para actualizar:
# cambiar versión y hash juntos, tomando el hash del release oficial.

# Nerd Fonts: solo la familia que usa cada config (y su licencia).
NERD_FONTS_VERSION="v3.5.1"
declare -A FONT_SHA256=(
  [Iosevka]="3b94ea1dc3955756762f977b7677bca671947dd56bc755a6f8465a8e83b5f257"
  [Hack]="cdd389472e10e2261520140ff1b382b4f8a226af5fd0b2735b975d31151d9c3c"
  [CascadiaCode]="ae598e9401e2846aa3ee364513715de0490b844a4b54f0768991f45f23aa8369"
)
# Iosevka -> polybar (texto e iconos); Hack Mono -> logo de Parrot en polybar;
# CaskaydiaCove -> kitty, dunst y rofi.
declare -A FONT_FILES=(
  [Iosevka]="IosevkaNerdFont-*"
  [Hack]="HackNerdFontMono-*"
  [CascadiaCode]="CaskaydiaCoveNerdFont-*"
)

# Neovim oficial: el de apt va varias versiones por detrás de lo que exige NvChad.
NVIM_VERSION="v0.12.5"
NVIM_SHA256="bce0f56eda1f1b1db6eee8f4133d7a38813ea07933837dd1777411ca384c6875"

# oh-my-posh (prompt). Binario del release, no `curl | bash` de un script remoto.
OMP_VERSION="v31.4.0"
OMP_SHA256="28ba5d5ec77fbcd6d2681674f6dd92760e07c5f4eb58927b6f9b03d1dd039fd4"

# nvm se clona en un tag concreto (instalación manual oficial, sin curl | bash).
# Node se fija por versión mayor: recibe los parches de seguridad de esa rama.
NVM_VERSION="v0.40.8"
NODE_MAJOR="24"

# =============================================================================
# PAQUETES DE APT
# =============================================================================
APT_PACKAGES=(
  # Entorno gráfico: WM, atajos, barra, compositor, lanzador, terminal, fondo,
  # notificaciones y utilidades de X11 (xkbcomp para el keymap, xset).
  bspwm sxhkd polybar picom rofi kitty feh dunst libnotify-bin
  x11-xkb-utils x11-xserver-utils
  # Shell y herramientas de terminal.
  zsh zsh-autosuggestions zsh-syntax-highlighting
  bat lsd fzf tmux ripgrep jq xclip
  # Bloqueo de pantalla. imagemagick es obligatorio: i3lock-fancy no funciona
  # con el sustituto de GraphicsMagick que apt acepta en su lugar.
  i3lock-fancy imagemagick
  # Desarrollo: git, análisis de shell scripts y lo que necesita Mason (nvim)
  # para descargar LSPs y formateadores.
  git shellcheck curl wget unzip xz-utils tar
  # Seguridad: firewall, anonimato, parches automáticos, claves y secretos.
  ufw anonsurf unattended-upgrades gnupg pinentry-curses pass keychain
  # Pentesting: VPN de los labs (HTB, THM), que crea la interfaz tun0 que
  # muestra la barra de VPN de polybar.
  openvpn
  # Base para fuentes y descargas HTTPS.
  fontconfig ca-certificates
  firefox-esr
)

# =============================================================================
# UTILIDADES
# =============================================================================
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

step() { echo -e "\n${BOLD}==> $1${NC}"; }
ok()   { echo -e "    ${GREEN}✓${NC} $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; }
die()  { echo -e "    ${RED}✗ $1${NC}" >&2; exit 1; }

# Carpeta temporal para descargas; se borra al salir, pase lo que pase.
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Descarga un archivo y verifica su SHA-256 antes de devolverlo.
# Uso: download_verified <url> <destino> <sha256>
download_verified() {
  local url=$1 dest=$2 sha=$3
  curl -fL --retry 3 --silent --show-error -o "$dest" "$url"
  if ! echo "$sha  $dest" | sha256sum --check --status; then
    rm -f "$dest"
    die "SHA-256 incorrecto para $url (descarga corrupta o manipulada)"
  fi
}

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# =============================================================================
# PASOS
# =============================================================================

check_prerequisites() {
  step "Comprobaciones previas"
  if [ "$EUID" -eq 0 ]; then
    die "Ejecútalo como tu usuario, no como root: ./bootstrap.sh (pedirá sudo)"
  fi
  # shellcheck source=/dev/null
  . /etc/os-release
  if [ "${ID:-}" != "parrot" ]; then
    warn "Pensado para Parrot OS (detectado: ${ID:-desconocido}); anonsurf puede no existir"
  fi
  if [ "${XDG_SESSION_TYPE:-x11}" = "wayland" ]; then
    warn "Sesión Wayland detectada: bspwm solo funciona en X11 (elige la sesión 'bspwm' al iniciar)"
  fi
  # Pedir la contraseña una sola vez y mantener sudo vivo mientras dure el
  # script, para no volver a pedirla a mitad de un paso largo.
  sudo -v
  while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
  ok "Usuario $USER, sudo disponible"
}

install_apt_packages() {
  step "Paquetes del sistema (apt)"
  local packages=("${APT_PACKAGES[@]}")
  # Integración con VMware (portapapeles, resolución, carpeta compartida).
  if [ "$(systemd-detect-virt 2>/dev/null || true)" = "vmware" ]; then
    packages+=(open-vm-tools-desktop)
  fi
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}"
  ok "${#packages[@]} paquetes instalados o ya presentes"
}

install_fonts() {
  step "Fuentes Nerd Fonts $NERD_FONTS_VERSION"
  local base="$HOME/.local/share/fonts/NerdFonts" name dest archive
  for name in "${!FONT_SHA256[@]}"; do
    dest="$base/$name"
    # Un archivo .version por familia permite saltar lo ya instalado y
    # reinstalar solo al cambiar NERD_FONTS_VERSION.
    if [ "$(cat "$dest/.version" 2>/dev/null)" = "$NERD_FONTS_VERSION" ]; then
      ok "$name ya instalada"
      continue
    fi
    archive="$TMP_DIR/$name.tar.xz"
    download_verified \
      "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/$name.tar.xz" \
      "$archive" "${FONT_SHA256[$name]}"
    rm -rf "$dest" && mkdir -p "$dest"
    # Solo la familia usada + la licencia (OFL/MIT exigen acompañar la fuente).
    tar -xJf "$archive" -C "$dest" --wildcards "${FONT_FILES[$name]}" 'LICENSE*'
    echo "$NERD_FONTS_VERSION" > "$dest/.version"
    ok "$name instalada ($(find "$dest" -name '*.ttf' | wc -l) archivos)"
  done
  fc-cache -f "$base" > /dev/null
}

install_neovim() {
  step "Neovim $NVIM_VERSION"
  local prefix=/opt/nvim-linux-x86_64 archive="$TMP_DIR/nvim.tar.gz"
  if "$prefix/bin/nvim" --version 2>/dev/null | head -1 | grep -q "NVIM $NVIM_VERSION$"; then
    ok "Ya instalado"
  else
    download_verified \
      "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" \
      "$archive" "$NVIM_SHA256"
    sudo rm -rf "$prefix"
    sudo tar -xzf "$archive" -C /opt
    ok "Instalado en $prefix"
  fi
  # El enlace en /usr/local/bin hace que nvim esté en el PATH estándar sin
  # tocar el PATH de la shell.
  sudo ln -sfn "$prefix/bin/nvim" /usr/local/bin/nvim
}

install_oh_my_posh() {
  step "oh-my-posh $OMP_VERSION"
  local bin="$HOME/.local/bin/oh-my-posh"
  if [ "$("$bin" version 2>/dev/null)" = "${OMP_VERSION#v}" ]; then
    ok "Ya instalado"
    return
  fi
  download_verified \
    "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/$OMP_VERSION/posh-linux-amd64" \
    "$TMP_DIR/oh-my-posh" "$OMP_SHA256"
  install -D -m 0755 "$TMP_DIR/oh-my-posh" "$bin"
  ok "Instalado en $bin"
}

install_node_toolchain() {
  step "nvm $NVM_VERSION + Node $NODE_MAJOR + pnpm + Claude Code"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -d "$NVM_DIR/.git" ]; then
    git clone --quiet --depth 1 --branch "$NVM_VERSION" https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  elif [ "$(git -C "$NVM_DIR" describe --tags 2>/dev/null)" != "$NVM_VERSION" ]; then
    git -C "$NVM_DIR" fetch --quiet --depth 1 origin tag "$NVM_VERSION"
    git -C "$NVM_DIR" -c advice.detachedHead=false checkout --quiet "$NVM_VERSION"
  fi
  ok "nvm $NVM_VERSION"
  # nvm usa variables sin inicializar: se desactiva -u solo mientras se usa.
  set +u
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  nvm install "$NODE_MAJOR" > /dev/null
  nvm alias default "$NODE_MAJOR" > /dev/null
  set -u
  ok "Node $(node --version)"
  # Globales de npm dentro del Node de nvm: no necesitan sudo.
  command -v pnpm > /dev/null || npm install -g --silent pnpm
  command -v claude > /dev/null || npm install -g --silent @anthropic-ai/claude-code
  ok "pnpm $(pnpm --version), Claude Code $(claude --version 2>/dev/null | cut -d' ' -f1)"
}

link_dotfiles() {
  step "Symlinks de configuración (install.sh)"
  "$DOTFILES_DIR/install.sh"
}

harden_system() {
  step "Hardening del sistema (system/setup.sh)"
  sudo "$DOTFILES_DIR/system/setup.sh"
}

set_default_shell() {
  step "Shell por defecto"
  local zsh_path
  zsh_path=$(command -v zsh)
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$zsh_path" ]; then
    ok "zsh ya es la shell por defecto"
  else
    sudo chsh -s "$zsh_path" "$USER"
    ok "zsh configurada (efectivo al volver a iniciar sesión)"
  fi
}

# Docker Engine oficial en modo rootless: el daemon corre como el usuario, sin
# root y sin grupo `docker` (pertenecer a ese grupo equivale a ser root).
install_docker_rootless() {
  step "Docker Engine (rootless)"
  local debian_major codename
  debian_major=$(cut -d. -f1 /etc/debian_version)
  case "$debian_major" in
    13) codename=trixie ;;
    12) codename=bookworm ;;
    *) die "Versión de Debian base no soportada: $(cat /etc/debian_version)" ;;
  esac
  # Clave de firma del repo de Docker: se comprueba su huella antes de
  # confiar en ella (la publicada en docs.docker.com).
  local key=/etc/apt/keyrings/docker.asc
  local docker_fpr="9DC858229FC7DD38854AE2D88D81803C0EBFCD88"
  curl -fsSL https://download.docker.com/linux/debian/gpg -o "$TMP_DIR/docker.asc"
  if ! gpg --show-keys --with-colons "$TMP_DIR/docker.asc" | grep -q "^fpr:.*:$docker_fpr:$"; then
    die "La clave de Docker no tiene la huella esperada ($docker_fpr)"
  fi
  sudo install -D -m 0644 "$TMP_DIR/docker.asc" "$key"
  sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $codename
Components: stable
Signed-By: $key
EOF
  # podman-docker instala su propio /usr/bin/docker: se retira para que el
  # comando `docker` sea inequívoco.
  if dpkg-query -W -f='${Status}' podman-docker 2>/dev/null | grep -q "ok installed"; then
    sudo apt-get remove -y -qq podman-docker
  fi
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    docker-compose-plugin docker-ce-rootless-extras \
    uidmap dbus-user-session slirp4netns
  # El daemon de sistema (root) no se usa: solo el del usuario.
  sudo systemctl disable --now docker.service docker.socket > /dev/null 2>&1 || true
  if ! systemctl --user is-active --quiet docker; then
    dockerd-rootless-setuptool.sh install > /dev/null
  fi
  systemctl --user enable --now docker > /dev/null 2>&1
  # linger: el daemon del usuario arranca con el sistema, sin esperar al login.
  sudo loginctl enable-linger "$USER"
  # El setuptool crea el contexto `rootless`; usarlo evita exportar DOCKER_HOST.
  docker context use rootless > /dev/null
  ok "$(docker --version)"
}

print_next_steps() {
  step "Listo. Pasos manuales que no se automatizan (implican secretos)"
  cat <<'EOF'
    1. Reinicia y en la pantalla de login elige la sesión "bspwm" (X11).
       En VMware: activa "Accelerate 3D graphics" en VM Settings -> Display.

    2. Clave SSH (autenticación en GitHub):
         ssh-keygen -t ed25519 -C "<usuario>@<maquina>"
       Sube ~/.ssh/id_ed25519.pub a GitHub -> Settings -> SSH and GPG keys.
       Guarda la passphrase en tu lugar seguro.

    3. Clave GPG (firma de commits y cifrado de pass):
         gpg --quick-generate-key "<nombre> <tu-noreply>@users.noreply.github.com" default default 2y
         git config --global user.email "<tu-noreply>@users.noreply.github.com"
         git config --global user.signingkey <fingerprint>
         git config --global commit.gpgsign true
         git config --global tag.gpgsign true
       Guarda la passphrase y un backup de la clave privada en tu lugar seguro.

    4. pass (gestor de secretos):
         pass init <fingerprint> && pass git init

    Detalle de cada paso en el README.
EOF
}

# =============================================================================
# EJECUCIÓN
# =============================================================================
WITH_DOCKER=false
for arg in "$@"; do
  case "$arg" in
    --with-docker) WITH_DOCKER=true ;;
    -h|--help) usage ;;
    *) die "Opción desconocida: $arg (ver --help)" ;;
  esac
done

check_prerequisites
install_apt_packages
install_fonts
install_neovim
install_oh_my_posh
install_node_toolchain
link_dotfiles
harden_system
set_default_shell
if [ "$WITH_DOCKER" = true ]; then
  install_docker_rootless
fi
print_next_steps
