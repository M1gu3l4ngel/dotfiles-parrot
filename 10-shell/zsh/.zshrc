# Interactive zsh configuration, loaded by every interactive shell (kitty, ssh). What could run
# once at login (PATH) lives here too, to keep one file.
#
# Reload without reopening the terminal: exec zsh (in each open terminal).
# The prompt is oh-my-posh with the capr4n theme, shared with dotfiles-windows.

# keychain keeps one ssh-agent across shells: the passphrase is asked once per boot. --quick
# reuses a running agent without checking its keys again (45 ms -> 19 ms per terminal).
[ -f "$HOME/.ssh/id_ed25519" ] && eval "$(keychain --eval --quiet --quick id_ed25519)"

# pinentry-gnome3 (gpg-agent.conf) asks for the passphrase in a dialog; with no graphical session
# (over SSH) it asks in the terminal, and GPG_TTY tells it which one. Without it, signing a commit
# over SSH fails with "gpg failed to sign the data". $TTY is zsh's own, cheaper than running `tty`.
export GPG_TTY=$TTY

# Prompt. The absolute path to oh-my-posh because ~/.local/bin joins PATH at the end of this file.
# The repo path comes from this file, a link to <repo>/10-shell/zsh/.zshrc: `%x` is this file,
# `:A` resolves the link and `:h:h` goes up to 10-shell/, so the prompt works wherever the repo is.
_dotfiles_dir=${${(%):-%x}:A:h:h}
[ -x "$HOME/.local/bin/oh-my-posh" ] && eval "$("$HOME/.local/bin/oh-my-posh" init zsh --config "$_dotfiles_dir/oh-my-posh/capr4n.omp.json")"
unset _dotfiles_dir

# History. Its own file name, so the default ~/.zsh_history can stay clean while testing.
HISTFILE=~/.zsh__history
HISTSIZE=10000
SAVEHIST=10000
# No duplicates, even apart; each command shows up at once in every terminal; and a command that
# starts with a space is not saved, for typing a token inline (" curl -H 'Authorization: ...'").
setopt histignorealldups sharehistory histignorespace

# A safety net for a forgotten leading space: lines with HTTP auth headers, bearer tokens,
# credential variables or sshpass never reach the history, which matters most in pentesting.
HISTORY_IGNORE='(*Authorization*|*Bearer *|*TOKEN=*|*SECRET=*|*PASSWORD=*|*API_KEY*|*sshpass*)'

# Grey suggestion of the next command from the history (Tab or Right accepts it).
# zsh-syntax-highlighting loads at the end of the file instead.
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

autoload -Uz compinit
compinit

# Double Esc adds `sudo` to the start of the current command, or removes it; on an empty line it
# brings back the last command first. It replaces the zsh-sudo plugin, broken on Parrot.
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

# Shift selection, as in an editor or Windows' PowerShell, which zsh lacks:
#   Shift+Left/Right       one character
#   Ctrl+Shift+Left/Right  one word
#   Shift+Home/End         to the start or end of the line
#   Backspace/Delete       deletes the selection; typing replaces it
# Starting a selection switches to the `shift-select` keymap, where any other key first closes the
# selection and then acts as usual. Ctrl+Shift+Left/Right needs kitty not to use them for tabs
# (kitty.conf).
shift-select::select-and-invoke() {
  if (( ! REGION_ACTIVE )); then
    zle set-mark-command -w
    zle -K shift-select
  fi
  zle ${WIDGET#shift-select::} -w
}

# Any key that is not a selection key: closes the selection and feeds the key ($KEYS) back to the
# normal keymap.
shift-select::deselect-and-input() {
  zle deactivate-region -w
  zle -K main
  zle -U "$KEYS"
}

# A printable character while selecting replaces the selection, as in an editor.
shift-select::replace-and-input() {
  zle kill-region -w
  zle -K main
  zle -U "$KEYS"
}

shift-select::delete-region() {
  zle kill-region -w
  zle -K main
}

zle -N shift-select::deselect-and-input
zle -N shift-select::replace-and-input
zle -N shift-select::delete-region

bindkey -N shift-select
bindkey -M shift-select -R '^@'-'^?' shift-select::deselect-and-input
bindkey -M shift-select -R ' '-'~' shift-select::replace-and-input
bindkey -M shift-select '^?' shift-select::delete-region    # Backspace
bindkey -M shift-select '^[[3~' shift-select::delete-region # Delete

# The sequences kitty sends for each combination (xterm format).
() {
  local seq widget
  for seq widget in \
    '^[[1;2D' backward-char \
    '^[[1;2C' forward-char \
    '^[[1;6D' backward-word \
    '^[[1;6C' forward-word \
    '^[[1;2H' beginning-of-line \
    '^[[1;2F' end-of-line; do
    zle -N shift-select::$widget shift-select::select-and-invoke
    bindkey -M emacs $seq shift-select::$widget
    bindkey -M shift-select $seq shift-select::$widget
  done
}

# Debian names bat's binary `batcat` to avoid a clash with another package; other distros call it
# `bat`. The alias appears only when needed, so the lines below work on both.
(( $+commands[bat] )) || alias bat='batcat'
alias cat='bat'
# Plain output, for pipes and scripts; catnp never pages either.
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'

alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

# How the completion menus look and behave.
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# `kill <Tab>` highlights the PIDs and shows what each process is.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# The colors ls and other tools use per file type: executables, archives, images, audio, backups.
LS_COLORS="rs=0:di=34:ln=36:mh=00:pi=40;33:so=35:do=35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=32:*.7z=31:*.ace=31:*.alz=31:*.apk=31:*.arc=31:*.arj=31:*.bz=31:*.bz2=31:*.cab=31:*.cpio=31:*.crate=31:*.deb=31:*.drpm=31:*.dwm=31:*.dz=31:*.ear=31:*.egg=31:*.esd=31:*.gz=31:*.jar=31:*.lha=31:*.lrz=31:*.lz=31:*.lz4=31:*.lzh=31:*.lzma=31:*.lzo=31:*.pyz=31:*.rar=31:*.rpm=31:*.rz=31:*.sar=31:*.swm=31:*.t7z=31:*.tar=31:*.taz=31:*.tbz=31:*.tbz2=31:*.tgz=31:*.tlz=31:*.txz=31:*.tz=31:*.tzo=31:*.tzst=31:*.udeb=31:*.war=31:*.whl=31:*.wim=31:*.xz=31:*.z=31:*.zip=31:*.zoo=31:*.zst=31:*.avif=35:*.jpg=35:*.jpeg=35:*.jxl=35:*.mjpg=35:*.mjpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.webp=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:"

# PATH is extended, never replaced with a fixed list: paths added by the system or other tools are
# kept, and nothing dead stays hardcoded after an uninstall. `typeset -U` drops the duplicates
# each `exec zsh` would add. The sbin folders hold network and pentest tools (tcpdump, iptables,
# ip) that Debian leaves out of a regular user's PATH. Neovim needs no entry: /usr/local/bin/nvim
# links to its binary in /opt.
typeset -U path
path+=(/usr/local/sbin /usr/sbin /sbin)

# State shared with polybar's modules: data that changes, not configuration. install.sh creates the
# folder and the scripts that read it use the same path.
_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

# Pentest target: the IP and machine name go to $_STATE_DIR/target, which victim_to_hack.sh reads
# to show it in polybar (target_module in the target_to_hack bar).
settarget() {
  # Validated before writing: a mistyped target in the bar can end in a scan against the wrong,
  # out-of-scope IP.
  local ip_address=$1 machine_name=$2 octet
  if (( $# != 2 )) || [[ ! $ip_address =~ '^([0-9]{1,3}\.){3}[0-9]{1,3}$' ]]; then
    print -u2 "Uso: settarget <IPv4> <nombre_maquina>   (ej: settarget 10.10.11.42 Lame)"
    return 1
  fi
  for octet in ${(s:.:)ip_address}; do
    if (( octet > 255 )); then
      print -u2 "settarget: '$ip_address' no es una IPv4 válida (octeto > 255)"
      return 1
    fi
  done
  # install.sh creates the folder too; this covers a manual install.
  mkdir -p "$_STATE_DIR"
  print -r -- "$ip_address $machine_name" > "$_STATE_DIR/target"
  # A dunst notification, like toggle_anonymity.sh, so it shows even when called from a script.
  # Font Awesome bullseye icon, U+F140.
  notify-send -u normal -t 3000 \
    $'\xef\x85\x80  Target establecido' \
    "$ip_address  ·  $machine_name"
}

cleartarget() {
  mkdir -p "$_STATE_DIR"
  # `: >` leaves the file at 0 bytes, not an empty line: the "no target" state victim_to_hack.sh
  # expects.
  : > "$_STATE_DIR/target"
  # Font Awesome eraser icon, U+F12D.
  notify-send -u low -t 3000 \
    $'\xef\x84\xad  Target limpiado' \
    "Sin objetivo activo"
}

# Demo mode for screenshots and videos: `demo on` makes polybar (Ethernet, VPN, target) and the
# prompt of every open terminal show fake data, so nothing real (IPs, targets, the user) is
# published. `demo off` brings the real data back and `demo` tells the state. Nothing in the system
# changes: the polybar modules show _DEMO_FILE instead of the real values while it exists.
#
# A fixed prompt name without demo mode: `export POSH_NAME=<name>` in ~/.zshenv (local, not
# versioned). The capr4n theme shows it instead of the user, as in dotfiles-windows.

# The format the modules read: "<ethernet> <vpn> <target_ip> <target_name> <prompt_name>". The
# values come from private and lab ranges, not real ones.
_DEMO_FILE="$_STATE_DIR/demo"
_DEMO_VALUES="192.168.10.100 10.10.14.23 10.10.11.42 Lame pentester"
typeset -gi _demo_active=0

demo() {
  case ${1-} in
    on)
      mkdir -p "${_DEMO_FILE:h}"
      print -r -- "$_DEMO_VALUES" >|"$_DEMO_FILE"
      notify-send -u low -t 3000 "Modo demo activado" "polybar y el prompt muestran datos falsos"
      ;;
    off)
      rm -f -- "$_DEMO_FILE"
      notify-send -u low -t 3000 "Modo demo desactivado" "Vuelven los datos reales"
      ;;
    "")
      if [[ -r $_DEMO_FILE ]]; then
        print -r -- "Modo demo: activado ($(<$_DEMO_FILE))"
      else
        print "Modo demo: desactivado"
      fi
      ;;
    *)
      print -u2 "Uso: demo [on|off]"
      return 1
      ;;
  esac
}

# Runs before each prompt and before oh-my-posh draws it (hence first in precmd_functions), so
# terminals that were already open change too. It acts only on entering or leaving demo mode, to
# keep a POSH_NAME of your own and give it back afterwards. zsh reads `$(<file)` without a process.
_demo_precmd() {
  if [[ -r $_DEMO_FILE ]]; then
    if ((!_demo_active)); then
      _demo_saved_name=${POSH_NAME-}
      _demo_active=1
    fi
    local -a fields=(${=$(<$_DEMO_FILE)})
    export POSH_NAME=${fields[5]}
  elif ((_demo_active)); then
    _demo_active=0
    if [[ -n $_demo_saved_name ]]; then
      export POSH_NAME=$_demo_saved_name
    else
      unset POSH_NAME
    fi
  fi
}
precmd_functions=(_demo_precmd $precmd_functions)

# fzf: Ctrl+R searches the history, Ctrl+T files and Alt+C changes directory. The apt package
# (signed and patched by unattended-upgrades), not a manual ~/.fzf; `fzf --zsh` prints the
# integration of the installed version (fzf >= 0.48), with no extra file in $HOME.
(( $+commands[fzf] )) && source <(fzf --zsh)

# nvm loads lazily: sourcing nvm.sh cost ~250 ms in every new terminal, most of kitty's opening
# delay. Instead, the default Node's bin/ (`nvm alias default`) goes straight into PATH, so node,
# npm, pnpm and claude work at once, and the `nvm` command loads the first time it is typed.
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/alias/default" ]; then
  # Installed versions that match the alias ("24" -> v24.*); (n) sorts numerically and (On) from
  # highest to lowest, so the newest one wins.
  _nvm_default=( "$NVM_DIR"/versions/node/v"$(<"$NVM_DIR/alias/default")"*(Nn/On) )
  (( ${#_nvm_default} )) && path=("${_nvm_default[1]}/bin" $path)
  unset _nvm_default
fi
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# ~/.local/bin first, so the user's binaries (oh-my-posh among them) win over the system's. The
# `path` array, not `export PATH=`, so `typeset -U` drops the duplicate on each `exec zsh`.
path=("$HOME/.local/bin" $path)

# zsh-syntax-highlighting must load last: it wraps the editing widgets that exist at that moment,
# and the ones defined later (sudo with double Esc, Shift selection) would not refresh the colors.
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  # Quoted text in cyan, as in PowerShell on Windows (the default is yellow). In hex, not `cyan`:
  # VSCodium's terminal uses its theme's palette, and this way it looks the same as in kitty.
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#58D1EB'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#58D1EB'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#58D1EB'
fi

# Selection (Shift+arrows): light background with dark text, as in PowerShell on Windows. The
# default inverted the highlight colors, so the background took each word's color.
zle_highlight=(region:bg=#C4C5B5,fg=#1A1A1A)
