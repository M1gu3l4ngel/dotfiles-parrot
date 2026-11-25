#!/usr/bin/env bash
# Links each configuration file of the repo to where its program reads it (lib/links.sh), plus the
# Claude Code layer from the dotfiles-windows clone, and merges ~/.claude/settings.json. Anything
# in the way is kept as a .pre-dotfiles.bak backup, which ./uninstall.sh restores. What is already
# right is skipped, so it runs again safely, and bootstrap.sh calls it.

set -euo pipefail

# The script's own folder, not ~/dotfiles: a clone elsewhere would otherwise get links to a folder
# that does not exist, and the whole desktop would break.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".pre-dotfiles.bak"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "    ${GREEN}✓${NC} $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; }
planned() { echo -e "    ${YELLOW}~${NC} $1"; }
die() {
  echo -e "    ${RED}✗ $1${NC}" >&2
  exit 1
}
# ~ instead of the full home: shorter, and the output does not show the user name.
short() { echo "${1/#"$HOME"/\~}"; }

usage() {
  cat <<'EOF'
Uso: ./install.sh [--dry-run | --check]

  (sin opción)  enlaza lo que falta, fusiona ~/.claude/settings.json y aplica
                los ajustes del escritorio
  --dry-run     muestra qué enlazaría, respaldaría, rehará o ajustaría, sin
                tocar nada
  --check       informa del estado de cada enlace y de ~/.claude/settings.json;
                sale con 1 si algo no está bien
  -h, --help    esta ayuda
EOF
  exit 0
}

MODE=install
for arg in "$@"; do
  case "$arg" in
    --dry-run) MODE=dry-run ;;
    --check) MODE=check ;;
    -h | --help) usage ;;
    *) die "Opción desconocida: $arg (ver --help)" ;;
  esac
done

# Copied out of the repo, the sources do not exist: fail with a clear message instead of making
# broken links.
if [ ! -f "$DOTFILES_DIR/lib/links.sh" ]; then
  die "install.sh debe ejecutarse dentro del repo (no existe $DOTFILES_DIR/lib/links.sh)"
fi
# shellcheck source=lib/links.sh
. "$DOTFILES_DIR/lib/links.sh"
LAYER=yes
if ! add_claude_layer_links; then
  LAYER=no
  warn "Capa de Claude Code omitida: falta $(short "$CLAUDE_LAYER_DIR")/links.json o node"
  warn "Clónala con: git clone https://github.com/M1gu3l4ngel/dotfiles-windows.git ~/dotfiles-windows"
fi
SETTINGS_TOOL="$CLAUDE_LAYER_DIR/tools/install-settings.mjs"

CHANGED=0
ALREADY=0

# Runs a change, or with --dry-run only names it. The first argument says what it does. A failure
# warns instead of stopping: these are side settings (dconf, systemd --user) that a session
# without a desktop bus cannot apply, and the links matter more.
change() {
  local what=$1
  shift
  if [ "$MODE" = dry-run ]; then
    planned "$what"
  elif "$@" >/dev/null 2>&1; then
    ok "$what"
  else
    warn "No se pudo: $what"
    return 0
  fi
  CHANGED=$((CHANGED + 1))
}

# Links source at target according to link_state. A foreign file is moved to .pre-dotfiles.bak
# first, with a date when a backup already exists: an older one may be the only copy of the
# original. If ln fails, the backup goes back, so the user never loses the file.
create_symlink() {
  local source=$1 target=$2 state backup=""
  if [ ! -e "$source" ]; then
    warn "No existe en el repo, se omite: $(short "$source")"
    return 0
  fi
  state=$(link_state "$source" "$target")
  if [ "$state" = ok ]; then
    ALREADY=$((ALREADY + 1))
    return 0
  fi
  CHANGED=$((CHANGED + 1))
  if [ "$state" = foreign ]; then
    backup="${target}${BACKUP_SUFFIX}"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      backup="${backup}.$(date +%Y%m%d%H%M%S)"
    fi
  fi
  if [ "$MODE" = dry-run ]; then
    case "$state" in
      missing) planned "Enlazaría: $(short "$target")" ;;
      stale) planned "Rehará el enlace a una ruta vieja: $(short "$target") (era $(short "$(readlink -- "$target")"))" ;;
      foreign) planned "Respaldaría $(short "$target") en $(short "$backup") y lo enlazaría" ;;
    esac
    return 0
  fi
  case "$state" in
    stale)
      # No trailing slash: rm removes the link itself, never what a folder link points to.
      warn "Enlace a una ruta vieja, se rehace: $(short "$target") (era $(short "$(readlink -- "$target")"))"
      rm -- "$target"
      ;;
    foreign)
      warn "Copia de seguridad: $(short "$target") -> $(short "$backup")"
      mv -- "$target" "$backup"
      ;;
  esac
  mkdir -p "$(dirname "$target")"
  if ! ln -s -- "$source" "$target"; then
    if [ -n "$backup" ]; then
      mv -- "$backup" "$target"
      warn "Restaurado el original: $(short "$target")"
    fi
    die "No se pudo crear el enlace: $(short "$target")"
  fi
  ok "Enlazado: $(short "$target")"
}

# --check: the same states an install would act on, changing nothing.
check_installation() {
  local link state bad=0
  local -A labels=([ok]="ok" [missing]="FALTA" [stale]="RUTA VIEJA" [foreign]="AJENO")
  for link in "${LINKS[@]}"; do
    state=$(link_state "${link%%|*}" "${link#*|}")
    [ "$state" = ok ] || bad=$((bad + 1))
    printf '  %-11s %s\n' "${labels[$state]}" "$(short "${link#*|}")"
  done
  if [ "$LAYER" = yes ]; then
    node "$SETTINGS_TOOL" --check || bad=$((bad + 1))
  else
    printf '  %-11s %s\n' FALTA "Capa de Claude Code ($(short "$CLAUDE_LAYER_DIR"))"
    bad=$((bad + 1))
  fi
  echo
  if [ "$bad" -eq 0 ]; then
    ok "Todo instalado: ${#LINKS[@]} enlaces y ~/.claude/settings.json"
    exit 0
  fi
  echo -e "    ${RED}✗${NC} $bad comprobaciones fallaron. Para arreglarlas: ./install.sh"
  exit 1
}

[ "$MODE" = check ] && check_installation
[ "$MODE" = dry-run ] && echo "    Simulación (--dry-run): no se modifica nada."

# ~/.gnupg goes before its gpg-agent.conf link: mkdir -p would create it 755, and gpg warns about
# "unsafe permissions" on an open home folder.
if [ ! -d "$HOME/.gnupg" ]; then
  change "Creado ~/.gnupg con permisos 700" mkdir -m 700 "$HOME/.gnupg"
elif [ "$(stat -c %a "$HOME/.gnupg")" != 700 ]; then
  change "Permisos 700 en ~/.gnupg" chmod 700 "$HOME/.gnupg"
fi

for link in "${LINKS[@]}"; do
  create_symlink "${link%%|*}" "${link#*|}"
done

# bspwmrc loads ~/.config/wallpaper.jpg. Only linked when there is none, so a wallpaper of the
# user's survives a second run.
if [ ! -e "$HOME/.config/wallpaper.jpg" ] && [ ! -L "$HOME/.config/wallpaper.jpg" ]; then
  change "Fondo de pantalla por defecto: ~/.config/wallpaper.jpg" \
    ln -s "$DOTFILES_DIR/assets/wallpaper.jpg" "$HOME/.config/wallpaper.jpg"
fi

# settarget (.zshrc) and polybar's target module share ~/.config/bin/target. Created empty, so
# victim_to_hack.sh does not fail when polybar starts before the first settarget.
create_target_file() { mkdir -p "$HOME/.config/bin" && : >"$HOME/.config/bin/target"; }
if [ ! -f "$HOME/.config/bin/target" ]; then
  change "Creado vacío ~/.config/bin/target" create_target_file
fi

# Merged, never linked: it holds this machine's home and what Claude Code writes on it. The tool
# adds the template's missing hooks, rules and status line with a dated backup.
if [ "$LAYER" = yes ]; then
  if [ "$MODE" = dry-run ]; then
    node "$SETTINGS_TOOL" --check >/dev/null || planned "Fusionaría lo que falta en ~/.claude/settings.json (detalle: ./install.sh --check)"
  else
    node "$SETTINGS_TOOL"
  fi
fi

# libadwaita (Nautilus) takes dark mode from this setting, stored in dconf, not in a file to link:
# without it, Nautilus opens light on a dark desktop.
if command -v gsettings >/dev/null &&
  [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" != "'prefer-dark'" ]; then
  change "Modo oscuro activado para las apps GTK4" gsettings set org.gnome.desktop.interface color-scheme prefer-dark
fi

# Apps that open a folder (Firefox's "Show in folder") use the inode/directory handler, which a
# code editor had taken.
FOLDER_APP="org.gnome.Nautilus.desktop"
if command -v xdg-mime >/dev/null && [ -f "/usr/share/applications/$FOLDER_APP" ] &&
  [ "$(xdg-mime query default inode/directory)" != "$FOLDER_APP" ]; then
  change "Carpetas asociadas al gestor de archivos (Nautilus)" xdg-mime default "$FOLDER_APP" inode/directory
fi

# Nautilus pulls in localsearch, which indexes every file in the background (constant CPU and
# disk). mask keeps it from starting even when Nautilus asks; search still walks the folders.
if command -v systemctl >/dev/null &&
  [ "$(systemctl --user is-enabled localsearch-3.service 2>/dev/null)" != "masked" ]; then
  change "Indexador de archivos (localsearch) desactivado" systemctl --user mask --now localsearch-3.service
fi

if [ "$MODE" = dry-run ]; then
  ok "$CHANGED cambios por hacer, $ALREADY enlaces ya estaban bien. Para aplicarlos: ./install.sh"
elif [ "$CHANGED" -eq 0 ]; then
  ok "Nada que cambiar: los $ALREADY enlaces ya estaban bien"
else
  ok "$CHANGED cambios hechos, $ALREADY enlaces ya estaban bien"
  echo "    Para cargarlos: exec zsh en cada terminal y Super+Alt+R"
fi
