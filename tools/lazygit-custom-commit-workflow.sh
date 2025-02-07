#!/usr/bin/env zsh

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/custom_functions.sh"
source "$HOME/dotfiles/scripts/fzf-git.sh"
source "$HOME/dotfiles/scripts/fzf-git-custom.sh"
source "$HOME/dotfiles/scripts/fzf-translate.sh"

local type_of_commit
type_of_commit=$(_fzf_commit_type_selector)
fzf_git_check_abort || return 1
file_or_folder=$(_create_fzf_select)
fzf_git_check_abort || return 1
message=$(_fzf_translate_main_function)
fzf_git_check_abort || return 1
echo -n "$type_of_commit $file_or_folder: $message" > /tmp/fzf_git_commit
create_commit module
fzf_git_check_abort || return 1

