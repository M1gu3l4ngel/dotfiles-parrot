# ~/.zshrc
# Configuración interactiva de zsh. Se carga al abrir cualquier shell
# interactiva (kitty, terminal de bspwm, ssh, etc.). Las cosas que necesitan
# correr SOLO una vez al login (export PATH, etc.) podrían ir en ~/.zprofile,
# pero por simplicidad este setup las mete aquí.
#
# Para recargar sin reabrir terminal:  exec zsh
# Prompt manejado por oh-my-posh con el tema capr4n (unificado con dotfiles-windows).

# ----- SSH AGENT (keychain) -----
# Mantiene el ssh-agent vivo entre sesiones de zsh. Pide la passphrase una
# sola vez por arranque de la VM y la cachea para los siguientes shells.
[ -f "$HOME/.ssh/id_ed25519" ] && eval $(keychain --eval --quiet id_ed25519)

# ----- PROMPT: OH-MY-POSH -----
# Prompt unificado con dotfiles-windows usando el tema capr4n.omp.json del
# mismo repo. Se usa $HOME/.local/bin/oh-my-posh (path absoluto) porque el
# PATH con ~/.local/bin se exporta al final de este archivo; de lo contrario
# el comando no se encontraría aquí. Para cambiar de tema, edita el .omp.json
# o sustituye por otro de ~/.cache/oh-my-posh/themes/ (built-ins).
[ -x "$HOME/.local/bin/oh-my-posh" ] && eval "$($HOME/.local/bin/oh-my-posh init zsh --config $HOME/dotfiles/oh-my-posh/capr4n.omp.json)"

# ----- HISTORIAL -----
# Doble underscore en HISTFILE para no chocar con el ~/.zsh_history default;
# así se puede mantener una copia limpia mientras se hacen pruebas.
HISTFILE=~/.zsh__history
HISTSIZE=10000
SAVEHIST=10000
# histignorealldups: no guardar duplicados (incluso no consecutivos).
# sharehistory: comandos de un terminal aparecen al instante en los demás.
setopt histignorealldups sharehistory

# ----- PLUGINS -----
# zsh-autosuggestions: muestra en gris la sugerencia del próximo comando
# basándose en el historial (Tab o → la acepta).
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting: colorea comandos válidos en verde, errores en rojo,
# strings, etc. Debe cargarse DESPUÉS de cualquier override del prompt.
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ----- SISTEMA DE COMPLETIONS -----
# compinit activa el sistema moderno de autocompletado (con menús, fuzzy match, etc.).
autoload -Uz compinit
compinit

# ----- ATAJO: SUDO CON DOBLE ESC -----
# Reemplazo del plugin zsh-sudo (que en Parrot está roto). Doble ESC añade
# `sudo` al inicio del comando actual, o lo quita si ya estaba; si la línea
# está vacía, sube al último comando del historial.
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

# =============================================================================
# ALIASES
# =============================================================================

# ----- bat (cat con syntax highlighting) -----
alias cat='bat'
# Sin línea de números ni separadores; útil para pipes y scripts.
alias catn='bat --style=plain'
# Igual pero sin paginar nunca (volcado directo a stdout).
alias catnp='bat --style=plain --paging=never'

# ----- lsd (ls con iconos y colores) -----
# group-dirs=first: directorios siempre arriba, archivos abajo.
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

# =============================================================================
# AJUSTES DE COMPLETIONS (zstyle)
# =============================================================================
# Configuran cómo se ven y se comportan los menús del autocompletado.
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

# Resaltar PIDs al autocompletar `kill <TAB>`, y mostrar info de cada proceso.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ----- LS_COLORS -----
# Paleta de colores que `ls` (y otras tools) usan para distinguir tipos de
# archivo: ejecutables, comprimidos, imágenes, audio, backups, etc.
LS_COLORS="rs=0:di=34:ln=36:mh=00:pi=40;33:so=35:do=35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=32:*.7z=31:*.ace=31:*.alz=31:*.apk=31:*.arc=31:*.arj=31:*.bz=31:*.bz2=31:*.cab=31:*.cpio=31:*.crate=31:*.deb=31:*.drpm=31:*.dwm=31:*.dz=31:*.ear=31:*.egg=31:*.esd=31:*.gz=31:*.jar=31:*.lha=31:*.lrz=31:*.lz=31:*.lz4=31:*.lzh=31:*.lzma=31:*.lzo=31:*.pyz=31:*.rar=31:*.rpm=31:*.rz=31:*.sar=31:*.swm=31:*.t7z=31:*.tar=31:*.taz=31:*.tbz=31:*.tbz2=31:*.tgz=31:*.tlz=31:*.txz=31:*.tz=31:*.tzo=31:*.tzst=31:*.udeb=31:*.war=31:*.whl=31:*.wim=31:*.xz=31:*.z=31:*.zip=31:*.zoo=31:*.zst=31:*.avif=35:*.jpg=35:*.jpeg=35:*.jxl=35:*.mjpg=35:*.mjpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.webp=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:"

# =============================================================================
# PATH Y EXTRAS
# =============================================================================

# ----- PATH PRINCIPAL -----
# /opt/kitty/bin     -> kitty instalado manualmente desde el binario oficial
# /opt/nvim-linux... -> Neovim instalado fuera del repo de apt (versión reciente)
# El resto son los paths estándar de Debian/Parrot.
export PATH="/opt/kitty/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/sbin/:/opt/nvim-linux-x86_64/bin"

# =============================================================================
# PENTEST: GESTIÓN DEL TARGET
# =============================================================================
# Guarda IP + nombre de la máquina actual en ~/.config/bin/target.
# Ese archivo lo lee el script victim_to_hack.sh para mostrarlo en polybar
# (módulo target_module → bar target_to_hack).

settarget() {
  ip_address=$1
  machine_name=$2
  # mkdir -p garantiza que el directorio exista la primera vez que se usa
  # (install.sh también lo crea, pero esto cubre el caso de instalación manual).
  mkdir -p "$HOME/.config/bin"
  echo "$ip_address $machine_name" > "$HOME/.config/bin/target"
  echo "Target establecido: $1 $2"
}

cleartarget() {
  mkdir -p "$HOME/.config/bin"
  echo '' > "$HOME/.config/bin/target"
  echo "Target limpiado"
}

# ----- FZF -----
# Fuzzy finder. Activa Ctrl+R (búsqueda en historial) y Ctrl+T (archivos).
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ----- NVM (Node Version Manager) -----
# Permite tener múltiples versiones de Node y cambiar entre ellas con `nvm use`.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ----- PATH FINAL: BINARIOS LOCALES DEL USUARIO -----
# Se añade al inicio del PATH para que `~/.local/bin/<algo>` tenga precedencia
# sobre la versión del sistema. Aquí también vive oh-my-posh (instalado vía curl).
export PATH="$HOME/.local/bin:$PATH"
