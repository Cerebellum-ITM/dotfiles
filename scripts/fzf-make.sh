check_makefile() {
    if [ ! -f Makefile ]; then
        [[ -n $TMUX ]] && tmux display-message "No Makefile found"
        return 1
    fi
}
_fzf_make_gui() {
    fzf-tmux -m -p80%,60% -- \
        --layout=reverse --multi --height=50% --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,50%,border-left' \
        --header='Select a target to run' \
        --preview="awk '/^{}[[:space:]]*:/ {flag=1; next} /^[^[:space:]]+:/ {flag=0} flag && /^[[:space:]]/' Makefile | bat --style=plain --language=shell --paging=always --pager=less"
}

_funtion_list() {
    check_makefile || return 1
    grep -E '^[^[:space:]]+:' Makefile | grep -v '^.PHONY' | cut -d: -f1 | _fzf_make_gui | xargs -I{} make {}
}
