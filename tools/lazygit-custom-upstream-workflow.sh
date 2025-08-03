#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/custom_functions.sh"
source "$HOME/dotfiles/tools/fzf-git-sourced.sh"
source "$HOME/dotfiles/scripts/fzf-git-custom.sh"

has_upstream() {
    git rev-parse --abbrev-ref --symbolic-full-name "${branch}@{u}" >/dev/null 2>&1
}

read -r branch
remote=$(_check_remote_source)

if has_upstream; then
    flag=""
    echo " Pushing to a remote for $(gum_green_dark_underline "${remote}")/$(gum_yellow_bold_underline "${branch}") branch has begun"
else
    flag="-u"
    echo " The upstream process for the $(gum_green_dark_underline "${remote}")/$(gum_yellow_bold_underline "${branch}") branch has begun"
fi

echo $flag

args=("remote=$remote" "branch=$branch")
if [[ -n $flag ]]; then
    args+=("flag=$flag")
fi

echo "${args[*]}"

_push_to_repository "${args[@]}"
