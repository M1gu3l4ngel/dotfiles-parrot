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

# The apt package list, one per line with `#` comments, kept out of the script as Windows keeps
# 60-apps/: what is installed changes far more often than how.
APT_LIST="$DOTFILES_DIR/60-apps/apt.txt"

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
Usage: ./bootstrap.sh [--dry-run]

  (no option)  full install: apt, fonts, Neovim, oh-my-posh, Node, Claude Code
               layer, links, VSCodium extensions, hardening and zsh
  --dry-run    shows what each step would do, without sudo, downloads or changes
  -h, --help   this help
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
    die "Wrong SHA-256 for $url (corrupt or tampered download)"
  fi
}

# ==== STEPS ====

check_prerequisites() {
  step "Prerequisites"
  if [ "$EUID" -eq 0 ]; then
    die "Run it as your user, not as root: ./bootstrap.sh (it asks for sudo)"
  fi
  # shellcheck source=/dev/null
  . /etc/os-release
  if [ "${ID:-}" != "parrot" ]; then
    warn "Meant for Parrot OS (found: ${ID:-unknown}); anonsurf may not exist"
  fi
  if [ "${XDG_SESSION_TYPE:-x11}" = "wayland" ]; then
    warn "Wayland session found: bspwm works only on X11 (pick the 'bspwm' session at login)"
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    ok "User $USER (dry run: sudo is not asked for)"
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
  ok "User $USER, sudo available"
}

install_apt_packages() {
  step "System packages (apt)"
  [ -f "$APT_LIST" ] || die "The package list does not exist: $APT_LIST"
  local packages=() line
  while IFS= read -r line; do
    line=${line%%#*}
    line=${line//[[:space:]]/}
    [ -n "$line" ] && packages+=("$line")
  done <"$APT_LIST"
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
    ok "All ${#packages[@]} packages are already installed"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Would install ${#missing[@]} packages: ${missing[*]}"
    return
  fi
  echo "    Installing ${#missing[@]} packages: ${missing[*]}"
  sudo apt-get update -qq
  # One apt transaction for all of them: dependencies are resolved once.
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
  ok "${#missing[@]} packages installed"
}

install_fonts() {
  step "Nerd Fonts $NERD_FONTS_VERSION"
  local base="$HOME/.local/share/fonts/NerdFonts" name dest archive changed=false
  for name in "${!FONT_SHA256[@]}"; do
    dest="$base/$name"
    # A .version file per family skips what is installed and reinstalls only when
    # NERD_FONTS_VERSION changes.
    if [ "$(cat "$dest/.version" 2>/dev/null)" = "$NERD_FONTS_VERSION" ]; then
      ok "$name already installed"
      continue
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      planned "Would download and install $name to $base"
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
    ok "$name installed ($(find "$dest" -name '*.ttf' | wc -l) files)"
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
    ok "Already installed"
  elif [ "$DRY_RUN" -eq 1 ]; then
    planned "Would download Neovim $NVIM_VERSION and install it to $prefix (sudo)"
  else
    download_verified \
      "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" \
      "$archive" "$NVIM_SHA256"
    sudo rm -rf "$prefix"
    sudo tar -xzf "$archive" -C /opt
    ok "Installed to $prefix"
  fi
  # A link in /usr/local/bin puts nvim on the standard PATH without touching the shell's.
  if [ "$(readlink /usr/local/bin/nvim 2>/dev/null)" = "$prefix/bin/nvim" ]; then
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Would link /usr/local/bin/nvim (sudo)"
  else
    sudo ln -sfn "$prefix/bin/nvim" /usr/local/bin/nvim
    ok "Linked /usr/local/bin/nvim"
  fi
}

install_oh_my_posh() {
  step "oh-my-posh $OMP_VERSION"
  local bin="$HOME/.local/bin/oh-my-posh"
  if [ "$("$bin" version 2>/dev/null)" = "${OMP_VERSION#v}" ]; then
    ok "Already installed"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Would download oh-my-posh $OMP_VERSION to $bin"
    return
  fi
  download_verified \
    "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/$OMP_VERSION/posh-linux-amd64" \
    "$TMP_DIR/oh-my-posh" "$OMP_SHA256"
  install -D -m 0755 "$TMP_DIR/oh-my-posh" "$bin"
  ok "Installed to $bin"
}

install_node_toolchain() {
  step "nvm $NVM_VERSION + Node $NODE_MAJOR + pnpm + Claude Code"
  export NVM_DIR="$HOME/.nvm"
  if [ "$DRY_RUN" -eq 1 ]; then
    if [ ! -d "$NVM_DIR/.git" ]; then
      planned "Would clone nvm $NVM_VERSION to $NVM_DIR and install Node $NODE_MAJOR, pnpm and Claude Code"
      return
    fi
    if [ "$(git -C "$NVM_DIR" describe --tags 2>/dev/null)" = "$NVM_VERSION" ]; then
      ok "nvm $NVM_VERSION"
    else
      planned "Would switch nvm to $NVM_VERSION"
    fi
    if compgen -G "$NVM_DIR/versions/node/v$NODE_MAJOR.*" >/dev/null; then
      ok "Node $NODE_MAJOR"
    else
      planned "Would install Node $NODE_MAJOR"
    fi
    local tool
    for tool in pnpm claude; do
      if compgen -G "$NVM_DIR/versions/node/v$NODE_MAJOR.*/bin/$tool" >/dev/null; then
        ok "$tool"
      else
        planned "Would install $tool with npm, at the pinned version"
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
  # nvm's progress goes to stderr and is dropped, with our own error and the command to retry by
  # hand if it fails.
  nvm install "$NODE_MAJOR" >/dev/null 2>&1 ||
    die "Could not install Node $NODE_MAJOR. Try by hand: nvm install $NODE_MAJOR"
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
  step "Claude Code layer (dotfiles-windows)"
  if [ -d "$CLAUDE_LAYER_CLONE/.git" ]; then
    ok "Already cloned to ~/dotfiles-windows"
  elif [ -e "$CLAUDE_LAYER_CLONE" ]; then
    die "There is a ~/dotfiles-windows that is not a git clone: move it and run again"
  elif [ "$DRY_RUN" -eq 1 ]; then
    planned "Would clone $CLAUDE_LAYER_REPO to ~/dotfiles-windows"
  else
    git clone --quiet "$CLAUDE_LAYER_REPO" "$CLAUDE_LAYER_CLONE"
    ok "Cloned to ~/dotfiles-windows"
  fi
}

link_dotfiles() {
  step "Configuration links (install.sh)"
  if [ "$DRY_RUN" -eq 1 ]; then
    "$DOTFILES_DIR/install.sh" --dry-run
  else
    "$DOTFILES_DIR/install.sh"
  fi
}

install_vscodium_extensions() {
  step "VSCodium extensions"
  local list="$DOTFILES_DIR/30-editor/vscodium/extensions.txt"
  if ! command -v codium >/dev/null; then
    warn "VSCodium is not installed; extensions skipped"
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
    ok "All ${#wanted[@]} extensions are already installed"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Would install $((${#args[@]} / 2)) extensions from Open VSX"
    return
  fi
  # All in one call, so VSCodium starts once and not once per extension. Its CLI prints a Node
  # deprecation notice (internal noise, not a failure) that is filtered; other errors still show.
  codium "${args[@]}" >/dev/null 2> >(grep -v -e DeprecationWarning -e trace-deprecation >&2)
  ok "$((${#args[@]} / 2)) extensions installed from Open VSX"
}

harden_system() {
  step "System hardening (70-system/setup.sh)"
  if [ "$DRY_RUN" -eq 1 ]; then
    planned "Would run sudo 70-system/setup.sh (idempotent: applies only what is missing)"
    return
  fi
  sudo "$DOTFILES_DIR/70-system/setup.sh"
}

set_default_shell() {
  step "Default shell"
  local zsh_path
  zsh_path=$(command -v zsh || echo /usr/bin/zsh)
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$zsh_path" ]; then
    ok "zsh is already the default shell"
  elif [ "$DRY_RUN" -eq 1 ]; then
    planned "Would change $USER's shell to $zsh_path (sudo)"
  else
    sudo chsh -s "$zsh_path" "$USER"
    ok "zsh set (takes effect at the next login)"
  fi
}

print_next_steps() {
  if [ "$DRY_RUN" -eq 1 ]; then
    step "Dry run finished: nothing changed. To apply it: ./bootstrap.sh"
    return
  fi
  step "Done. Manual steps left out on purpose (they involve secrets)"
  cat <<'EOF'
    1. Reboot and pick the "bspwm" session (X11) on the login screen.
       On VMware: turn on "Accelerate 3D graphics" in VM Settings -> Display.

    2. SSH key (GitHub authentication):
         ssh-keygen -t ed25519 -C "<user>@<machine>"
       Upload ~/.ssh/id_ed25519.pub to GitHub -> Settings -> SSH and GPG keys.
       Keep the passphrase somewhere safe.

    3. GPG key (commit signing and pass encryption):
         gpg --quick-generate-key "<name> <your-noreply>@users.noreply.github.com" default default 2y
         git config --file ~/.gitconfig.local user.signingkey <fingerprint>
       The name, the noreply email and signing already come from 15-git/gitconfig.
       Never git config --global: it would write into the repo through the link.
       Keep the passphrase and a backup of the private key somewhere safe.

    4. pass (secrets manager):
         pass init <fingerprint> && pass git init

    Details of each step in README.md (in Spanish: README.es.md).
EOF
}

# ==== RUN ====
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h | --help) usage ;;
    *) die "Unknown option: $arg (see --help)" ;;
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
