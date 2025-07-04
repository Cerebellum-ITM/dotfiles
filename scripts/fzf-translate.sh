# shellcheck shell=bash
# shellcheck disable=SC2296
__fzf_translate_script=${BASH_SOURCE[0]:-${(%):-%x}}
FZF_TRANSLATE_HISTORY_FILE="$HOME/dotfiles/home/.config/.tmp/.fzf-translate_history.log"

if [[ "$1" == "_request_translation" ]]; then
    commit_message="$2"
    # translate_message=$(trans es:en "$commit_message" -4 -b)
    translate_message=$(python3 "$HOME/dotfiles/python/groq_translate_api.py" "$commit_message")
    echo "$PWD ~ $commit_message ~ $translate_message" | sed "s/'//g" >> "$FZF_TRANSLATE_HISTORY_FILE"
    exit 0
fi

if [[ "$1" == "_preview_translation" ]]; then
    entry="$2"
    grep "^$PWD ~ $entry" "$FZF_TRANSLATE_HISTORY_FILE" | awk -F " ~ " '{print $3}' | head -n 1
    exit 0
fi

_fzf_translate_main_function() {
    entry=$(_fzf_translate_gui)
    echo "$(grep "^$PWD ~ $entry" "$FZF_TRANSLATE_HISTORY_FILE" | awk -F " ~ " '{print $3}' | head -n 1)"
}

_fzf_translate_gui() {
    grep "^$PWD ~" "$FZF_TRANSLATE_HISTORY_FILE" | sed "s|^$PWD ~ ||" | awk -F " ~ " '{print $1}' | \
    awk '{ lines[NR] = $0 } END { for (i = NR; i > 0; i--) print lines[i] }' | \
    fzf-tmux --ansi -m -p80%,60% -- \
    --layout=reverse --multi --height=50% --min-height=20 --border \
    --border-label-pos=2 \
    --color='header:italic:underline,label:blue' \
    --prompt='New message: ' \
    --preview-window='down,50%,border-top' \
    --header="Select the message - CTRL+W: Translate query - CTRL-X (abort)" \
    --preview="bash $__fzf_translate_script _preview_translation {}" \
    --preview-label 'English Translation' \
    --bind "ctrl-x:execute-silent(echo 130 > /tmp/fzf_git_exit_code)+abort" \
    --bind "ctrl-w:execute-silent(bash $__fzf_translate_script _request_translation \"{q}\")+reload(grep \"^$PWD ~\" \"$FZF_TRANSLATE_HISTORY_FILE\" | sed \"s|^$PWD ~ ||\" | awk -F \" ~ \" '{print \$1}')"
}
