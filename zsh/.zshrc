# ---- SSH agent (keychain) ----
# Mantiene el ssh-agent vivo entre sesiones de zsh.
# Pide passphrase 1 vez por arranque de la VM.
eval $(keychain --eval --quiet id_ed25519)

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
source /home/bytebit/powerlevel10k/powerlevel10k.zsh-theme

# History
HISTFILE=~/.zsh__history
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups sharehistory

# Plugins

# ZSH AutoSuggestions

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
	source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ZSH Syntax Highlighting 

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Use modern completion system
autoload -Uz compinit
compinit

# Sudo con doble ESC (reemplazo de zsh-sudo broken)
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

# Custom Aliases
# -----------------------------------------------
# bat
alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'
 
# ls
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
 
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
 
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# LS_COLORS
LS_COLORS="rs=0:di=34:ln=36:mh=00:pi=40;33:so=35:do=35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=32:*.7z=31:*.ace=31:*.alz=31:*.apk=31:*.arc=31:*.arj=31:*.bz=31:*.bz2=31:*.cab=31:*.cpio=31:*.crate=31:*.deb=31:*.drpm=31:*.dwm=31:*.dz=31:*.ear=31:*.egg=31:*.esd=31:*.gz=31:*.jar=31:*.lha=31:*.lrz=31:*.lz=31:*.lz4=31:*.lzh=31:*.lzma=31:*.lzo=31:*.pyz=31:*.rar=31:*.rpm=31:*.rz=31:*.sar=31:*.swm=31:*.t7z=31:*.tar=31:*.taz=31:*.tbz=31:*.tbz2=31:*.tgz=31:*.tlz=31:*.txz=31:*.tz=31:*.tzo=31:*.tzst=31:*.udeb=31:*.war=31:*.whl=31:*.wim=31:*.xz=31:*.z=31:*.zip=31:*.zoo=31:*.zst=31:*.avif=35:*.jpg=35:*.jpeg=35:*.jxl=35:*.mjpg=35:*.mjpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.webp=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:"

#PATH
export PATH="/opt/kitty/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/sbin/:/opt/nvim-linux-x86_64/bin"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Pentest target management
function settarget(){
    ip_address=$1
    machine_name=$2
    echo "$ip_address $machine_name" > /home/bytebit/.config/bin/target
    echo "Target establecido: $1 $2"
}

function cleartarget(){
    echo '' > /home/bytebit/.config/bin/target
    echo "Target limpiado"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"
