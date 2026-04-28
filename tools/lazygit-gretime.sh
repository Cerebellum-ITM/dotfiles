#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"
source "$HOME/dotfiles/scripts/git_retime.sh"

gretime "$@"
