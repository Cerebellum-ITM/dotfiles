if [ "STERM PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/.oh-my-posh/prompt_config.toml)"
fi

export XDG_CONFIG_HOME="$HOME/.config"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

export LC_ALL=en_US.UTF-8
export LSCOLORS="Gxfxcxdxbxegedabagacad" 

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -f "$HOME/dotfiles/home/.config/atuin/sync-server.env" ]; then
  source "$HOME/dotfiles/home/.config/atuin/sync-server.env"
fi

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

# Keybindings
bindkey '^[OA' history-search-backward
bindkey '^[OB' history-search-forward
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word


HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

export BAT_THEME=tokyonight_night
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview='[[ -d {} ]] && eza --tree --color=always --icons {} || bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# Aliases
alias ls='eza --color=always --long --git --icons=always'
alias vim='nvim'
alias cat='bat'
alias f='fzf'
alias fc='fzf-code'
alias fm='fzf-make'
alias fcat='bat $(f)'
alias fg='fzf-git'
alias frm='rm -rf $(fzf_select -m)'
alias ft='_odoo_template_list'
alias it='$HOME/dotfiles/scripts/odoo_developer_tools.sh'
alias s='source ~/.zshrc'
alias kk="printf '\n%.0s' {1..100}"

# Shell integrations
eval "$(zoxide init zsh --cmd cd)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

source ~/dotfiles/tools/tput-config.sh
source ~/dotfiles/home/.config/.tmp/.docker-compose-config
source ~/dotfiles/tools/gum_styles.sh
source ~/dotfiles/tools/gum_log_functions.sh

for file in $HOME/dotfiles/scripts/*.sh; do
    source "$file"
done

function history_clean() {
    FZF_TRANSLATE_HISTORY_FILE="$HOME/dotfiles/home/.config/.tmp/.fzf-translate_history.log"
    FZF_MAKE_HISTORY_FILE="$HOME/dotfiles/home/.config/.tmp/.fzf-make_history.log"
    tail -n 3000 "$FZF_TRANSLATE_HISTORY_FILE" > "$FZF_TRANSLATE_HISTORY_FILE.tmp" && mv "$FZF_TRANSLATE_HISTORY_FILE.tmp" "$FZF_TRANSLATE_HISTORY_FILE"
    tail -n 3000 "$FZF_MAKE_HISTORY_FILE" > "$FZF_MAKE_HISTORY_FILE.tmp" && mv "$FZF_MAKE_HISTORY_FILE.tmp" "$FZF_MAKE_HISTORY_FILE"
}

get_ip() {
    local ip_address=$(hostname -I | awk '{print $1}')
    blue_bold "The IP address is: $ip_address"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "$ip_address" | pbcopy
        green_bold "The IP address has been copied to the clipboard."
    elif command -v xclip &> /dev/null; then
        echo "$ip_address" | xclip -selection clipboard
        green_bold "The IP address has been copied to the clipboard."
    elif command -v xsel &> /dev/null; then
        echo "$ip_address" | xsel --clipboard --input
        green_bold "The IP address has been copied to the clipboard."
    else
        red_bold "Could not copy the IP address to the clipboard."
    fi
}

fzf-code(){
    local actual_path=$(pwd)
    if [[ "$1" == "open-directory" || "$1" == "." ]]; then
        code . -r
    elif [[ "$1" == "new-window" || "$1" == "-nw" ]]; then
        code .
    elif [[ "$1" == "create" || "$1" == "-c" ]]; then
        local file_name=$2
        code $file_name
    elif [[ "$1" == "open" || "$1" == "-o" ]]; then
        local file_name=$(fzf_select)
        code $file_name
    elif [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "List of available commands:\n- $(blue_bold 'open-directory') or $(purple_underlie '.')\n- $(green_bold 'new-window') or $(purple_underlie '-nw')\n- $(green_bold 'create') or $(purple_underlie '-c') $(purple_underlie '<file_name>')\n- $(green_bold 'open') or $(purple_underlie '-o')"
    else
        echo "For the list of available commands, run $(green_bold 'fcode help') or $(green_bold 'fcode -h')"
    fi
}

printf '\n%.0s' {1..100}

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
