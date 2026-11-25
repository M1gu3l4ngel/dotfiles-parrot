#!/usr/bin/env bash
# Full install on a fresh Parrot OS in one command, as a regular user (it asks for sudo once and
# uses it only for apt, /opt and /etc):
#
#   git clone https://github.com/M1gu3l4ngel/dotfiles-parrot.git ~/dotfiles
#   cd ~/dotfiles && ./bootstrap.sh
#
# Each step checks what is already done, and at which version, and applies only what is missing:
# it runs again safely after a failure or to update a pinned version. --dry-run shows what each
# step would do without sudo, downloads or changes.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==== PINNED VERSIONS ====
# Everything that does not come from apt is downloaded at a fixed version and checked against the
# SHA-256 kept here: a corrupt or tampered download stops the install. To update, change version
# and hash together, taking the hash from the official release.

# Nerd Fonts: only the family each config uses, and its license.
NERD_FONTS_VERSION="v3.5.1"
declare -A FONT_SHA256=(
  [Hack]="cdd389472e10e2261520140ff1b382b4f8a226af5fd0b2735b975d31151d9c3c"
  [CascadiaCode]="ae598e9401e2846aa3ee364513715de0490b844a4b54f0768991f45f23aa8369"
)
# CaskaydiaCove for all text (polybar, kitty, dunst and rofi); Hack Mono only for the Parrot logo
# in polybar.
declare -A FONT_FILES=(
  [Hack]="HackNerdFontMono-*"
  [CascadiaCode]="CaskaydiaCoveNerdFont-*"
)

# Official Neovim: apt's is several versions behind what NvChad needs.
NVIM_VERSION="v0.12.5"
NVIM_SHA256="bce0f56eda1f1b1db6eee8f4133d7a38813ea07933837dd1777411ca384c6875"

# oh-my-posh (prompt): the release binary, not `curl | bash` of a remote script.
OMP_VERSION="v31.4.0"
OMP_SHA256="28ba5d5ec77fbcd6d2681674f6dd92760e07c5f4eb58927b6f9b03d1dd039fd4"

# nvm is cloned at a tag (the official manual install, no curl | bash). Node is pinned by major
# version, so it gets that line's security patches.
NVM_VERSION="v0.40.8"
NODE_MAJOR="24"
# npm globals, checked by npm against the registry's integrity hash. Installed at this version
# only when missing: Claude Code updates itself, and forcing the pin on every run would undo that.
PNPM_VERSION="12.8.1"
CLAUDE_CODE_VERSION="2.1.332"

# The Claude Code layer: dotfiles-windows is its single source on every machine, next to this
# repo as Windows keeps ~\dotfiles-parrot.
CLAUDE_LAYER_REPO="https://github.com/M1gu3l4ngel/dotfiles-windows.git"
CLAUDE_LAYER_CLONE="$HOME/dotfiles-windows"

# ==== APT PACKAGES ====
APT_PACKAGES=(
  # Desktop: window manager, hotkeys, bar, compositor, launcher, terminal, wallpaper,
  # notifications, file manager and X11 tools (xkbcomp for the keymap, xset).
  bspwm sxhkd polybar picom rofi kitty feh dunst libnotify-bin nautilus
  x11-xkb-utils x11-xserver-utils
  # Shell and terminal tools.
  zsh zsh-autosuggestions zsh-syntax-highlighting
  bat lsd fzf tmux ripgrep jq xclip
  # Development: git, the GitHub CLI (rulesets, topics and the new-repo skill), shell script
  # checks, what Mason (nvim) needs to fetch LSPs and formatters, and VSCodium (VS Code without
  # telemetry, from Parrot's repository).
  git gh shellcheck shfmt curl wget unzip xz-utils tar codium
  # Security: firewall, anonymity, automatic patches, keys and secrets.
  ufw anonsurf unattended-upgrades gnupg pinentry-gnome3 pass keychain
  # Pentesting: the labs' VPN (HTB, THM), whose tun0 interface polybar's VPN module shows, and
  # dig for the anonymity DNS leak tests (docs/anonymity.md).
  openvpn bind9-dnsutils
  # Fonts and HTTPS downloads, and glxinfo (mesa-utils) to check graphics acceleration
  # (docs/vmware.md).
  fontconfig ca-certificates mesa-utils
  firefox-esr
)

# ==== HELPERS ====
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

step() { echo -e "\n${BOLD}==> $1${NC}"; }
ok() { echo -e "    ${GREEN}✓${NC} $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; }
planned() { echo -e "    ${YELLOW}~${NC} $1"; }
die() {
  echo -e "    ${RED}✗ $1${NC}" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Uso: ./bootstrap.sh [--dry-run]

  (sin opción)  instalación completa: apt, fuentes, Neovim, oh-my-posh, Node,
                capa de Claude Code, enlaces, extensiones de VSCodium,
                hardening y zsh
  --dry-run     muestra qué haría cada paso, sin sudo, descargas ni cambios
  -h, --help    esta ayuda
EOF
  exit 0
}

DRY_RUN=0

# Downloads go to a temporary folder removed on exit, whatever happens.
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Downloads a file and checks its SHA-256 before handing it over.
download_verified() {
  local url=$1 dest=$2 sha=$3
  curl -fL --retry 3 --silent --show-error -o "$dest" "$url"
  if ! echo "$sha  $dest" | sha256sum --check --status; then
    rm -f "$dest"
    die "SHA-256 incorrecto para $url (descarga corrupta o manipulada)"
  fi
}

# ==== STEPS ====

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
  if [ "$DRY_RUN" -eq 1 ]; then
    ok "Usuario $USER (simulación: no se pide sudo)"
    return
  fi
  # The password once, and sudo kept alive while the script runs, so a long step never stops to
  # ask again.
  sudo -v
  while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" 2>/dev/null || exit
  done 2>/dev/null &
  ok "Usuario $USER, sudo disponible"
}

install_apt_packages() {
  step "Paquetes del sistema (apt)"
  local packages=("${APT_PACKAGES[@]}")
  # VMware integration: clipboard, resolution, shared folder.
  if [ "$(systemd-detect-virt 2>/dev/null || true)" = "vmware" ]; then
    packages+=(open-vm-tools-desktop)
  fi
  # Only what is missing, and with nothing missing no `apt-get update`, which fetches every
  # repository index and is the slowest part of a rerun. One dpkg query for all packages.
  local -A installed=()
  local pkg status missing=()
  while read -r pkg status; do
    [ "$status" = "ii" ] && installed[$pkg]=1
  done < <(dpkg-query -W -f='${Package} ${db:Status-Abbrev}\n' "${packages[@]}" 2>/dev/null || true)
  for pkg in "${packages[@]}"; do
    [ -n "${installed[$pkg]:-}" ] || missing+=("$pkg")
  done
  if [ "${#missing[@]}" -eq 0 ]; then
    ok "Los ${#packages[@]} paquetes ya están instalados"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Instalaría ${#missing[@]} paquetes: ${missing[*]}"
    return
  fi
  echo "    Instalando ${#missing[@]} paquetes: ${missing[*]}"
  sudo apt-get update -qq
  # One apt transaction for all of them: dependencies are resolved once.
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
  ok "${#missing[@]} paquetes instalados"
}

install_fonts() {
  step "Fuentes Nerd Fonts $NERD_FONTS_VERSION"
  local base="$HOME/.local/share/fonts/NerdFonts" name dest archive changed=false
  for name in "${!FONT_SHA256[@]}"; do
    dest="$base/$name"
    # A .version file per family skips what is installed and reinstalls only when
    # NERD_FONTS_VERSION changes.
    if [ "$(cat "$dest/.version" 2>/dev/null)" = "$NERD_FONTS_VERSION" ]; then
      ok "$name ya instalada"
      continue
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      planned "Descargaría e instalaría $name en $base"
      continue
    fi
    archive="$TMP_DIR/$name.tar.xz"
    download_verified \
      "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/$name.tar.xz" \
      "$archive" "${FONT_SHA256[$name]}"
    rm -rf "$dest" && mkdir -p "$dest"
    # Only the family in use plus its license: OFL and MIT require shipping it with the font.
    tar -xJf "$archive" -C "$dest" --wildcards "${FONT_FILES[$name]}" 'LICENSE*'
    echo "$NERD_FONTS_VERSION" >"$dest/.version"
    ok "$name instalada ($(find "$dest" -name '*.ttf' | wc -l) archivos)"
    changed=true
  done
  if [ "$changed" = true ]; then
    fc-cache -f "$base" >/dev/null
  fi
}

install_neovim() {
  step "Neovim $NVIM_VERSION"
  local prefix=/opt/nvim-linux-x86_64 archive="$TMP_DIR/nvim.tar.gz"
  if "$prefix/bin/nvim" --version 2>/dev/null | head -1 | grep -q "NVIM $NVIM_VERSION$"; then
    ok "Ya instalado"
  elif [ "$DRY_RUN" -eq 1 ]; then
    planned "Descargaría Neovim $NVIM_VERSION y lo instalaría en $prefix (sudo)"
  else
    download_verified \
      "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" \
      "$archive" "$NVIM_SHA256"
    sudo rm -rf "$prefix"
    sudo tar -xzf "$archive" -C /opt
    ok "Instalado en $prefix"
  fi
  # A link in /usr/local/bin puts nvim on the standard PATH without touching the shell's.
  if [ "$(readlink /usr/local/bin/nvim 2>/dev/null)" = "$prefix/bin/nvim" ]; then
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Enlazaría /usr/local/bin/nvim (sudo)"
  else
    sudo ln -sfn "$prefix/bin/nvim" /usr/local/bin/nvim
    ok "Enlazado /usr/local/bin/nvim"
  fi
}

install_oh_my_posh() {
  step "oh-my-posh $OMP_VERSION"
  local bin="$HOME/.local/bin/oh-my-posh"
  if [ "$("$bin" version 2>/dev/null)" = "${OMP_VERSION#v}" ]; then
    ok "Ya instalado"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Descargaría oh-my-posh $OMP_VERSION en $bin"
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
  if [ "$DRY_RUN" -eq 1 ]; then
    if [ ! -d "$NVM_DIR/.git" ]; then
      planned "Clonaría nvm $NVM_VERSION en $NVM_DIR, e instalaría Node $NODE_MAJOR, pnpm y Claude Code"
      return
    fi
    if [ "$(git -C "$NVM_DIR" describe --tags 2>/dev/null)" = "$NVM_VERSION" ]; then
      ok "nvm $NVM_VERSION"
    else
      planned "Cambiaría nvm a $NVM_VERSION"
    fi
    if compgen -G "$NVM_DIR/versions/node/v$NODE_MAJOR.*" >/dev/null; then
      ok "Node $NODE_MAJOR"
    else
      planned "Instalaría Node $NODE_MAJOR"
    fi
    local tool
    for tool in pnpm claude; do
      if compgen -G "$NVM_DIR/versions/node/v$NODE_MAJOR.*/bin/$tool" >/dev/null; then
        ok "$tool"
      else
        planned "Instalaría $tool con npm, en la versión fijada"
      fi
    done
    return
  fi
  if [ ! -d "$NVM_DIR/.git" ]; then
    git clone --quiet --depth 1 --branch "$NVM_VERSION" https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  elif [ "$(git -C "$NVM_DIR" describe --tags 2>/dev/null)" != "$NVM_VERSION" ]; then
    git -C "$NVM_DIR" fetch --quiet --depth 1 origin tag "$NVM_VERSION"
    git -C "$NVM_DIR" -c advice.detachedHead=false checkout --quiet "$NVM_VERSION"
  fi
  ok "nvm $NVM_VERSION"
  # nvm reads unset variables: -u is off only while it runs.
  set +u
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  # nvm writes its progress in English to stderr: dropped, with our own error and the command to
  # retry by hand if it fails.
  nvm install "$NODE_MAJOR" >/dev/null 2>&1 ||
    die "No se pudo instalar Node $NODE_MAJOR. Prueba a mano: nvm install $NODE_MAJOR"
  nvm alias default "$NODE_MAJOR" >/dev/null
  set -u
  ok "Node $(node --version)"
  # npm globals inside nvm's Node: no sudo needed.
  command -v pnpm >/dev/null || npm install -g --silent "pnpm@$PNPM_VERSION"
  command -v claude >/dev/null || npm install -g --silent "@anthropic-ai/claude-code@$CLAUDE_CODE_VERSION"
  ok "pnpm $(pnpm --version), Claude Code $(claude --version 2>/dev/null | cut -d' ' -f1)"
}

# Only cloned when missing: an existing clone is the user's to pull, and may hold work in progress.
clone_claude_layer() {
  step "Capa de Claude Code (dotfiles-windows)"
  if [ -d "$CLAUDE_LAYER_CLONE/.git" ]; then
    ok "Ya clonada en ~/dotfiles-windows"
  elif [ -e "$CLAUDE_LAYER_CLONE" ]; then
    die "Existe ~/dotfiles-windows y no es un clon de git: muévelo y vuelve a ejecutar"
  elif [ "$DRY_RUN" -eq 1 ]; then
    planned "Clonaría $CLAUDE_LAYER_REPO en ~/dotfiles-windows"
  else
    git clone --quiet "$CLAUDE_LAYER_REPO" "$CLAUDE_LAYER_CLONE"
    ok "Clonada en ~/dotfiles-windows"
  fi
}

link_dotfiles() {
  step "Enlaces de configuración (install.sh)"
  if [ "$DRY_RUN" -eq 1 ]; then
    "$DOTFILES_DIR/install.sh" --dry-run
  else
    "$DOTFILES_DIR/install.sh"
  fi
}

install_vscodium_extensions() {
  step "Extensiones de VSCodium"
  local list="$DOTFILES_DIR/30-editor/vscodium/extensions.txt"
  if ! command -v codium >/dev/null; then
    warn "VSCodium no está instalado; se omiten las extensiones"
    return
  fi
  # One query for the installed ones; codium lists them in lower case.
  local -A installed=()
  local id
  while read -r id; do
    installed[${id,,}]=1
  done < <(codium --list-extensions 2>/dev/null)
  local wanted=() args=()
  while read -r id; do
    id=${id%%#*}
    id=${id//[[:space:]]/}
    [ -n "$id" ] || continue
    wanted+=("$id")
    [ -n "${installed[${id,,}]:-}" ] || args+=(--install-extension "$id")
  done <"$list"
  if [ "${#args[@]}" -eq 0 ]; then
    ok "Las ${#wanted[@]} extensiones ya están instaladas"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Instalaría $((${#args[@]} / 2)) extensiones desde Open VSX"
    return
  fi
  # All in one call, so VSCodium starts once and not once per extension. Its CLI prints a Node
  # deprecation notice (internal noise, not a failure) that is filtered; other errors still show.
  codium "${args[@]}" >/dev/null 2> >(grep -v -e DeprecationWarning -e trace-deprecation >&2)
  ok "$((${#args[@]} / 2)) extensiones instaladas desde Open VSX"
}

harden_system() {
  step "Hardening del sistema (70-system/setup.sh)"
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Ejecutaría sudo 70-system/setup.sh (idempotente: solo aplica lo que falte)"
    return
  fi
  sudo "$DOTFILES_DIR/70-system/setup.sh"
}

set_default_shell() {
  step "Shell por defecto"
  local zsh_path
  zsh_path=$(command -v zsh || echo /usr/bin/zsh)
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$zsh_path" ]; then
    ok "zsh ya es la shell por defecto"
  elif [ "$DRY_RUN" -eq 1 ]; then
    planned "Cambiaría la shell de $USER a $zsh_path (sudo)"
  else
    sudo chsh -s "$zsh_path" "$USER"
    ok "zsh configurada (efectivo al volver a iniciar sesión)"
  fi
}

print_next_steps() {
  if [ "$DRY_RUN" -eq 1 ]; then
    step "Simulación terminada: no se cambió nada. Para aplicarlo: ./bootstrap.sh"
    return
  fi
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
         git config --file ~/.gitconfig.local user.signingkey <fingerprint>
       El nombre, el email noreply y la firma ya vienen de 15-git/gitconfig.
       Nunca git config --global: escribiría en el repo a través del enlace.
       Guarda la passphrase y un backup de la clave privada en tu lugar seguro.

    4. pass (gestor de secretos):
         pass init <fingerprint> && pass git init

    Detalle de cada paso en README.es.md (en inglés: README.md).
EOF
}

# ==== RUN ====
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h | --help) usage ;;
    *) die "Opción desconocida: $arg (ver --help)" ;;
  esac
done

check_prerequisites
install_apt_packages
install_fonts
install_neovim
install_oh_my_posh
install_node_toolchain
clone_claude_layer
link_dotfiles
install_vscodium_extensions
harden_system
set_default_shell
print_next_steps
