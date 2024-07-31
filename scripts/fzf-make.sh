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

_funtion_list() {
    check_makefile || return 1
    local selected_commands=$(grep -E '^[^[:space:]]+:' Makefile | grep -v '^.PHONY' | cut -d: -f1 | _fzf_make_gui)
    if [ -n "$selected_commands" ]; then
        IFS=$'\n' commands_array=()
        while IFS= read -r line; do
            commands_array+=("$line")
        done <<< "$selected_commands"
        
        for cmd in "${commands_array[@]}"; do
            make "$cmd"
        done
    fi
}
