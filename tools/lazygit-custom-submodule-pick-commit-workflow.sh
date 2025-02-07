#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/custom_functions.sh"
source "$HOME/dotfiles/scripts/fzf-git.sh"
source "$HOME/dotfiles/scripts/fzf-git-custom.sh"
source "$HOME/dotfiles/scripts/fzf-translate.sh"

read -r commit_hash
parent_folder=$(basename "$(dirname "$PWD")")
_check_for_git_repository_and_submodule || return 1
echo " creating a commit in the repository $(gum_blue "$parent_folder") with the commit: $(gum_yellow_bold_underline "${commit_hash}")"

commit_message=$(git log -1 --pretty=%B "$commit_hash")
submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
file_or_folder=$(echo "$commit_message" | sed -E 's/.*\] ([^:]+):.*/\1/')
message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
create_commit submodule
fzf_git_check_abort || return 1
