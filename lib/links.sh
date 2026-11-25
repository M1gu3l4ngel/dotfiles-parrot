#!/usr/bin/env bash
# The link map shared by install.sh and uninstall.sh, so the two can never disagree, and the
# state of a link on disk. Sourced, never run: it needs DOTFILES_DIR set first.
#
# Each entry is "source|target". The Claude Code layer is not listed here: it comes from
# 50-claude/links.json of the dotfiles-windows clone, its single source on every machine.

# shellcheck disable=SC2034 # LINKS is used by the scripts that source this file.
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
  # File by file, not the whole ~/.config/gtk-4.0: other apps keep their state there.
  "$DOTFILES_DIR/gtk/.config/gtk-4.0/gtk.css|$HOME/.config/gtk-4.0/gtk.css"
  "$DOTFILES_DIR/gtk/.config/gtk-4.0/settings.ini|$HOME/.config/gtk-4.0/settings.ini"
  # Parrot's VSCodium reads its settings from "Visual Studio Code", not from VSCodium.
  "$DOTFILES_DIR/vscodium/settings.json|$HOME/.config/Visual Studio Code/User/settings.json"
  "$DOTFILES_DIR/vscodium/keybindings.json|$HOME/.config/Visual Studio Code/User/keybindings.json"
  # Only the file: ~/.gnupg holds the private keys and must stay a real 700 folder outside any
  # repo (install.sh creates it that way before linking).
  "$DOTFILES_DIR/gnupg/.gnupg/gpg-agent.conf|$HOME/.gnupg/gpg-agent.conf"
  "$DOTFILES_DIR/nvim/.config/nvim|$HOME/.config/nvim"
  "$DOTFILES_DIR/scripts/.config/scripts|$HOME/.config/scripts"
  "$DOTFILES_DIR/zsh/.zshrc|$HOME/.zshrc"
  # Default style for projects without their own. No leading dot in the repo, or it would apply
  # to format/ itself.
  "$DOTFILES_DIR/format/prettierrc.json|$HOME/.prettierrc.json"
  "$DOTFILES_DIR/format/editorconfig|$HOME/.editorconfig"
)

# The dotfiles-windows clone sits next to this repo, as Windows keeps ~\dotfiles-parrot.
CLAUDE_LAYER_DIR="${CLAUDE_LAYER_DIR:-$HOME/dotfiles-windows/50-claude}"

# Links that point anywhere inside these folders are ours: a different path there is a moved
# file, replaced without a backup because it holds nothing the repos do not.
OWNED_ROOTS=("$DOTFILES_DIR" "$CLAUDE_LAYER_DIR")

# Appends the Claude Code layer from links.json (source relative to 50-claude/, target to
# ~/.claude/). Returns 1, adding nothing, when the clone or node is missing.
add_claude_layer_links() {
  [ -f "$CLAUDE_LAYER_DIR/links.json" ] && command -v node >/dev/null || return 1
  local entry
  # shellcheck disable=SC2016 # ${...} is JavaScript, read by node, not by the shell.
  while IFS= read -r entry; do
    LINKS+=("$CLAUDE_LAYER_DIR/${entry%%|*}|$HOME/.claude/${entry#*|}")
  done < <(node -e 'for (const l of require(process.argv[1]).links) console.log(`${l.source}|${l.target}`)' \
    "$CLAUDE_LAYER_DIR/links.json")
}

# Prints the state of target against source, changing nothing:
#   ok       a symlink to exactly source
#   missing  nothing at target
#   stale    a symlink to another path inside OWNED_ROOTS
#   foreign  a real file or folder, or a symlink elsewhere: backed up before linking
# -L comes first: a broken symlink fails -e but is still a link.
link_state() {
  local source=$1 target=$2 dest root
  if [ ! -L "$target" ]; then
    if [ -e "$target" ]; then echo foreign; else echo missing; fi
    return 0
  fi
  dest=$(readlink -- "$target")
  if [ "$dest" = "$source" ]; then
    echo ok
    return 0
  fi
  for root in "${OWNED_ROOTS[@]}"; do
    case "$dest" in "$root"/*)
      echo stale
      return 0
      ;;
    esac
  done
  echo foreign
}
