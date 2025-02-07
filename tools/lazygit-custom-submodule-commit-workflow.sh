#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/custom_functions.sh"
source "$HOME/dotfiles/scripts/fzf-git.sh"
source "$HOME/dotfiles/scripts/fzf-git-custom.sh"
source "$HOME/dotfiles/scripts/fzf-translate.sh"

repository_name=$(basename "$PWD")
echo " creating a commit in the repository $(gum_blue "$repository_name")"

_check_for_git_repository_and_submodule || return 1
module_list=''
changelog_exists=false
type_of_commit=$(_fzf_commit_type_selector)
fzf_git_check_abort || return 1
file_or_folder=$(_create_fzf_select)
fzf_git_check_abort || return 1
message=$(_fzf_translate_main_function)
fzf_git_check_abort || return 1
echo -n "$type_of_commit $file_or_folder: $message" > /tmp/fzf_git_commit
_check_for_changelog
create_commit module
gum spin --spinner dot --title "$(git_strong_red ) Starting the $(git_strong_red commit) process in the $(gum_blue_bold_underline parent) repository" -- sleep 0.5
fzf_git_check_abort || return 1
submodule_commit_type="${type_of_commit//[^a-zA-Z0-9]/}"
echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
create_commit submodule
fzf_git_check_abort || return 1