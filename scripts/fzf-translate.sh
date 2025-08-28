# shellcheck shell=bash
# shellcheck disable=SC2296
git_pwd_context="/tmp/git_pwd_context"
git_commit_preamble_file="/tmp/fzf_git_commit_preamble"
__fzf_translate_script="$HOME/dotfiles/scripts/fzf-translate.sh"

if [[ "$1" == "_request_translation" ]]; then

    unset context
    unset preamble
    unset translate_message

    if [ -f "$git_commit_preamble_file" ] && [ -s "$git_commit_preamble_file" ]; then
        preamble=$(cat "$git_commit_preamble_file")
        rm "$git_commit_preamble_file"
    fi

    if [ -f "$git_pwd_context" ] && [ -s "$git_pwd_context" ]; then
        context=$(cat "$git_pwd_context")
        rm "$git_pwd_context"
    fi

    commit=$2
    commit=${commit#\'}
    commit=${commit%\'}

    if [[ -n "$commit" ]]; then
        translate_message=$(python3 "$HOME/dotfiles/python/translate_commit_tool/groq_translate_api.py" "$commit" "$context" "$preamble")
    fi

    if [[ -n "$translate_message" ]]; then
        python3 "$HOME/dotfiles/python/translate_commit_tool/insert_commit.py" "$PWD" "$commit" "$translate_message"
    fi

    exit 0
fi

if [[ "$1" == "_preview_translation" ]]; then
    IFS=$'\t' read -r entry rest <<<"$2"
    python3 "$HOME/dotfiles/python/translate_commit_tool/query_commits.py" "get_commit_by_id" "$entry"
    exit 0
fi

_fzf_translate_get_pwd_commits() {
    python3 "$HOME/dotfiles/python/translate_commit_tool/query_commits.py" "get_all_commits" "$PWD" |
        awk -F $'\t' '
            BEGIN { OFS = "\t"; rec = "" }
                /^[0-9]+\t/ {
                if (rec != "") { process(rec) }
                rec = $0
                next
            }
            { rec = rec " " $0 }
            END { if (rec != "") process(rec) }

            function process(r,   n,i,a,msg) {
                n = split(r, a, "\t")
                if (n >= 5) { msg = a[4]; for (i=5;i<=n-1;i++) msg = msg OFS a[i] }
                else { msg = a[4] }
                gsub(/\r?\n/, " ", msg); gsub(/\r/, "", msg)
                print a[1] OFS a[2] OFS msg
            }
        '
}

if [[ "$1" == "_update_pwd_commits" ]]; then
    _fzf_translate_get_pwd_commits
fi

if [[ "$1" == "_remove_element_from_db" ]]; then
    IFS=$'\t' read -r id _ _ <<<"$2"
    python3 "$HOME/dotfiles/python/translate_commit_tool/delete_commit.py" "$id"
fi

if [[ "$1" == "_change_query" ]]; then
    IFS=$'\t' read -r _ _ entry <<<"$2"
    echo "$entry"
fi

_fzf_translate_main_function() {
    {
        git diff --cached --name-only | while read file; do
            echo "=== $file ==="
            git diff --cached --unified=0 -- "$file"
        done
    } >"$git_pwd_context"

    entry=$(_fzf_translate_gui)
    if [[ -z "$entry" ]]; then
        echo "$(gum style --foreground="#FF0000" "") $(gum style --foreground='808080' 'No entry selected. Exiting.')"
        return 1
    fi

    IFS=$'\t' read -r id rest <<<"$entry"
    python3 "$HOME/dotfiles/python/translate_commit_tool/query_commits.py" "get_commit_by_id" "$id"
}

_fzf_translate_gui() {
    _fzf_translate_get_pwd_commits |
        fzf-tmux --ansi -m -p80%,60% -- \
            --layout=reverse --multi --height=50% --min-height=20 --border \
            --tac \
            --border-label-pos=2 \
            --color='header:italic:underline,label:blue' \
            --prompt='Commit: ' \
            --preview-window='down,50%,border-top' \
            --header="Select the message - CTRL+W: Translate query - CTRL-X (abort)" \
            --preview="bash $__fzf_translate_script _preview_translation {}" \
            --preview-label 'English Translation' \
            --bind "ctrl-x:execute-silent(echo 130 > /tmp/fzf_git_exit_code)+abort" \
            --bind "ctrl-q:transform-query:(bash $__fzf_translate_script _change_query {})" \
            --bind "ctrl-r:execute-silent(bash $__fzf_translate_script _remove_element_from_db {})+reload(bash $__fzf_translate_script _update_pwd_commits)" \
            --bind "ctrl-w:execute-silent(bash $__fzf_translate_script _request_translation {q})+reload(bash $__fzf_translate_script _update_pwd_commits)"
}
