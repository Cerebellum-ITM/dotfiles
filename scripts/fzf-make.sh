FZF_MAKE_HISTORY_FILE="$HOME/dotfiles/zsh/.fzf-make_history.log"

check_makefile() {
    if [ ! -f Makefile ]; then
        [[ -n $TMUX ]] && tmux display-message "No Makefile found"
        return 1
    fi
}
_fzf_make_gui() {
    fzf-tmux --ansi	-m -p80%,60% -- \
        --layout=reverse --multi --height=50% --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,80%,border-left' \
        --header='Select the commands to run' \
        --preview="awk '/^{}[[:space:]]*:/ {flag=1; next} /^[^[:space:]]+:/ {flag=0} flag && /^[[:space:]]/' Makefile | sed 's/^\t//' | bat --style='${BAT_STYLE:-full}' --color=always --paging=always --pager='less -FRX' --language=sh"
}

log_history() {
    local selection="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $PWD - $selection" >> "$FZF_MAKE_HISTORY_FILE"
}

_funtion_list() {
    check_makefile || return 1
    local selected_commands=$(grep -E '^[^[:space:]]+:' Makefile | grep -v '^.PHONY' | cut -d: -f1 | _fzf_make_gui)
    if [ -n "$selected_commands" ]; then
        local original_ifs="$IFS"
        IFS=$'\n' commands_array=()
        while IFS= read -r line; do
            commands_array+=("$line")
        done <<< "$selected_commands"
        IFS="$original_ifs"
        
        local history_entry=""

        for cmd in "${commands_array[@]}"; do
            make "$cmd"
            history_entry+="$cmd, "
        done

        history_entry="${history_entry%, }"
        log_history "$history_entry"
    fi
}

view_history() {
    if [ ! -f "$FZF_MAKE_HISTORY_FILE" ]; then
        echo "No history file found."
        return 1
    fi

    cat "$FZF_MAKE_HISTORY_FILE" | fzf --ansi --preview 'echo {} | awk -F" - " "{print \$3}"' --preview-window=down:3:wrap

    local current_dir="$PWD"
    
    grep " - $current_dir -" "$FZF_MAKE_HISTORY_FILE" | awk -F' - ' '{print $1}' | \
    fzf --ansi --preview "grep -F ' - $current_dir - ' '$FZF_MAKE_HISTORY_FILE' | grep -F '^{}' | awk -F' - ' '{print \$3}'" --preview-window=down:3:wrap
}