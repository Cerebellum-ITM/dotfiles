#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/custom_functions.sh"
source "$HOME/dotfiles/scripts/fzf-git.sh"
source "$HOME/dotfiles/scripts/fzf-git-custom.sh"
source "$HOME/dotfiles/scripts/fzf-translate.sh"

repository_name=$(basename "$PWD")
echo " creating a commit in the repository $(gum_blue "$repository_name")"
commit_message=$(commitcraft)
if [ -z "$commit_message" ]; then
    gun_log_fatal "$(git_strong_red 󰊢) - the creation of the commit was canceled"
    exit 1
fi
echo -n "$commit_message" >/tmp/fzf_git_commit
create_commit module
fzf_git_check_abort || return
