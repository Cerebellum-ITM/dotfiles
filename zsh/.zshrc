if [ "STERM PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/dotfiles/zsh/oh-my-posh/prompt_config.toml)"
fi


ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

export LSCOLORS="Gxfxcxdxbxegedabagacad" 

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

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
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# Aliases
alias ls='ls --color'
alias vim='nvim'
alias cat='bat'
alias f='fzf'
alias fcode='code $(f)'
alias fcat='bat $(f)'
alias fg='fgit'
alias frm='rm -rf $(fzf_select -m)'
alias ft='_odoo_template_list'
# Shell integrations
eval "$(zoxide init zsh --cmd cd)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
source ~/dotfiles/scripts/fzf-git.sh
source ~/dotfiles/scripts/fzf-make.sh
source ~/dotfiles/scripts/tput-config.sh
source ~/dotfiles/scripts/fzf-templates.sh
source ~/dotfiles/scripts/fzf-translate.sh

function history_clean() {
    FZF_TRANSLATE_HISTORY_FILE="$HOME/dotfiles/zsh/.fzf-translate_history.log"
    FZF_MAKE_HISTORY_FILE="$HOME/dotfiles/zsh/.fzf-make_history.log"
    tail -n 3000 "$FZF_TRANSLATE_HISTORY_FILE" > "$FZF_TRANSLATE_HISTORY_FILE.tmp" && mv "$FZF_TRANSLATE_HISTORY_FILE.tmp" "$FZF_TRANSLATE_HISTORY_FILE"
    tail -n 3000 "$FZF_MAKE_HISTORY_FILE" > "$FZF_MAKE_HISTORY_FILE.tmp" && mv "$FZF_MAKE_HISTORY_FILE.tmp" "$FZF_MAKE_HISTORY_FILE"
}


function dotfiles_update() {
    cd $HOME/dotfiles
    git pull
    ./install.sh --unattended
    history_clean
    source ~/.zshrc
    cd -
}

fzf_select() {
    trap 'rm -f /tmp/initial_path' EXIT

    local multi_select=""
    if [[ "$1" == "-m" ]]; then
        multi_select="-m"
        echo $multi_select > /tmp/fzf_select_multi
    fi

    if [[ -f /tmp/fzf_select_multi ]]; then
        multi_select=$(cat /tmp/fzf_select_multi)
        rm /tmp/fzf_select_multi
    fi
    
    if [[ ! -f /tmp/initial_path ]]; then
        echo $PWD > /tmp/initial_path
    fi
    
    local mode="${1:-select}"
    while true; do
        if [[ "$mode" == "select" ]]; then
            header="Modo: SELECT (ctrl-w para cambiar a PATH CHANGER)"
            color="header:bright-green"
        else
            header="Modo: PATH CHANGER (ctrl-s para cambiar a SELECT)"
            color="header:bright-magenta"
        fi

        selected=$(find . -maxdepth 1 -mindepth 1 -type d -o -type f 2> /dev/null | \
            awk 'BEGIN {print ".."} {print}' | \
            FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border \
                --preview='[[ -d {} ]] && tree -L 1 {} || bat -n --color=always {}' \
                --header='$header' \
                --color='$color' \
                --bind 'ctrl-w:execute-silent(echo path_changer > /tmp/fzf_mode && echo $multi_select > /tmp/fzf_select_multi)+abort' \
                --bind 'ctrl-s:execute-silent(echo select > /tmp/fzf_mode && echo $multi_select > /tmp/fzf_select_multi)+abort'" \
            fzf $multi_select)

        if [[ -z "$selected" ]]; then
            break
        fi

        if [[ "$selected" == ".." ]]; then
            cd ..
            fzf_select "$mode" $multi_select
        elif [[ "$mode" == "path_changer" && -d "$selected" ]]; then
            cd "$selected"
            fzf_select "select" $multi_select
        else
            if [[ -n "$multi_select" ]]; then
                echo $selected
            else
                echo "$(basename "$selected")"
            fi
            initial_path=$(cat /tmp/initial_path)
            cd $initial_path
            rm /tmp/initial_path
        fi
        break
    done

    if [[ -f /tmp/fzf_mode ]]; then
        mode=$(cat /tmp/fzf_mode)
        rm /tmp/fzf_mode
        fzf_select "$mode" $multi_select
    fi
}

fgit() {
    if [[ "$1" == "log" || "$1" == "-l" ]]; then
        _fzf_git_hashes 
    elif [[ "$1" == "status" || "$1" == "-s" ]]; then
        _fzf_git_files
    elif [[ "$1" == "commit" || "$1" == "-sc" ]]; then
        _fzf_git_files
        local type_of_commit
        type_of_commit=$(awk -F': ' '{print $1 "\t" $2}' $HOME/dotfiles/git/commits_guide_lines.txt | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 --color=fg:yellow,hl:green,preview-fg:white --preview-window='right,90%,border-left' --delimiter="\t" --with-nth=1 --preview="echo {} | cut -f2" | cut -f1)
        file_or_folder=$(fzf_select)
        message=$(_fzf_translate_main_funtion)
        print -z "git commit -m\"$type_of_commit $file_or_folder: $message\""
    elif [[ "$1" == "checkout" || "$1" == "-ck" ]]; then
        git checkout $(_fzf_git_branches)
    elif [[ "$1" == "cherry" || "$1" == "-c" ]]; then
        git cherry-pick $(_fzf_git_hashes)
    elif [[ "$1" == "remote" || "$1" == "-v" ]]; then
        _fzf_git_remotes
    elif [[ "$1" == "stash" ]]; then
        _fzf_git_stashes
    elif [[ "$1" == "push-interactive" || "$1" == "-pi" ]]; then
        remote=$(_fzf_git_remotes)
        branch=$(_fzf_git_branches)
        git push $remote $branch 
    elif [[ "$1" == "push-interactive-upstream" || "$1" == "-piu" ]]; then
        remote=$(_fzf_git_remotes)
        branch=$(_fzf_git_branches)
        git push -u $remote $branch 
    elif [[ "$1" == "push" || "$1" == "-p" ]]; then
        git push  
    elif [[ "$1" == "push-force" || "$1" == "-pf" ]]; then
        git push -f
    else
        echo "List of available commands:\n- log or -l (default)\n- cherry or -c\n- status or -s\n- checkout or -ck\n- remote or -v\n- stash or -st\n- push or -p\n- push-force or -pf\n- push-interactive or -pi\n- push-interactive-upstream or -piu"
    fi
}

fm() {
    if [[ "$1" == "repeat" || "$1" == "-r" ]]; then
        execute_commands "$(grep "$(pwd)" "$FZF_MAKE_HISTORY_FILE" | sort -r | awk -F ' - ' '{print $3}' | head -n 1 | sed 's/ *, */,/g' | tr ',' '\n')"
    elif [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "List of available commands:\n- repeat or -r"
    else
        select_or_history       
    fi
}