#!/bin/bash

source $HOME/dotfiles/tools/log_functions.sh

local OSTYPE=$1

remove_if_exists() {
    if [ -e "$1" ]; then
        rm -rf "$1"
        echo "Removed $1"
    else
        echo "$1 does not exist"
    fi
}

remove_if_exists "$HOME/.zshrc"
remove_if_exists "$HOME/oh-my-posh"
remove_if_exists "$HOME/.config/bat"
remove_if_exists "$HOME/.config/.tmp"

if [ "$1" == 'darwin' ]; then
    remove_if_exists "$HOME/.config/karabiner"
    remove_if_exists "$HOME/.config/ghostty"
fi

cd $HOME/dotfiles/home && stow .