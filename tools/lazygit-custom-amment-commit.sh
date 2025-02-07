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
echo "Running an $(git_strong_red "amendment") of the last  commit in the repository $(gum_blue "$repository_name")"

git commit --amend --no-edit
_force_push_to_repository