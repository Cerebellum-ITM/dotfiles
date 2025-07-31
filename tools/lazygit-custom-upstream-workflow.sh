#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/custom_functions.sh"
source "$HOME/dotfiles/tools/fzf-git-sourced.sh"
source "$HOME/dotfiles/scripts/fzf-git-custom.sh"

read -r branch
echo " The upstream process for the $(gum_yellow_bold_underline "${branch}" branch has begun)"
remote=$(_check_remote_source)
_push_to_repository "remote=$remote" "branch=$branch" "flag=-u"
