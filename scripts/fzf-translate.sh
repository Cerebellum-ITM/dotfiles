# shellcheck shell=bash
# shellcheck disable=SC2296
__fzf_translate_script=${BASH_SOURCE[0]:-${(%):-%x}}

if [[ "$1" == "_request_translation" ]]; then
    commit=$2
    commit=${commit#\'}
    commit=${commit%\'}
    translate_message=$(python3 "$HOME/dotfiles/python/translate_commit_tool/groq_translate_api.py" "$commit")
    python3 "$HOME/dotfiles/python/translate_commit_tool/insert_commit.py" "$PWD" "$commit" "$translate_message"
    exit 0
fi

if [[ "$1" == "_preview_translation" ]]; then
    IFS=$'\t' read -r entry rest <<< "$2"
    python3 "$HOME/dotfiles/python/translate_commit_tool/query_commits.py" "get_commit_by_id" "$entry"
    exit 0
fi


_fzf_translate_get_pwd_commits() {
    python3 "$HOME/dotfiles/python/translate_commit_tool/query_commits.py" "get_all_commits" "$PWD" | awk -F'\t' '{print $1 "\t" $2 "\t" $4}'
}

if [[ "$1" == "_update_pwd_commits" ]]; then
    _fzf_translate_get_pwd_commits 
fi


_fzf_translate_main_function() {
    entry=$(_fzf_translate_gui)
    IFS=$'\t' read -r id rest <<< "$entry"
    python3 "$HOME/dotfiles/python/translate_commit_tool/query_commits.py" "get_commit_by_id" "$id"
}

_fzf_translate_gui() {
    _fzf_translate_get_pwd_commits | \
    fzf-tmux --ansi -m -p80%,60% -- \
    --layout=reverse --multi --height=50% --min-height=20 --border \
    --border-label-pos=2 \
    --color='header:italic:underline,label:blue' \
    --prompt='Commit: ' \
    --preview-window='down,50%,border-top' \
    --header="Select the message - CTRL+W: Translate query - CTRL-X (abort)" \
    --preview="bash $__fzf_translate_script _preview_translation {}" \
    --preview-label 'English Translation' \
    --bind "ctrl-x:execute-silent(echo 130 > /tmp/fzf_git_exit_code)+abort" \
    --bind "ctrl-r:execute-silent(bash $__fzf_translate_script _remove_element_from_db {})+reload(bash $__fzf_translate_script _update_pwd_commits)" \
    --bind "ctrl-w:execute-silent(bash $__fzf_translate_script _request_translation {q})+reload(bash $__fzf_translate_script _update_pwd_commits)"
}
