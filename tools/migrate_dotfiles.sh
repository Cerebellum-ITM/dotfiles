#!/bin/bash

OSTYPE=$1
source "$HOME/dotfiles/tools/log_functions.sh"

remove_if_exists() {
    if [ -e "$1" ]; then
        rm -rf "$1"
        log_info "Removed $1"
    else
        log_warning "$1 does not exist"
    fi
}

remove_if_exists "$HOME/.zshrc"
remove_if_exists "$HOME/oh-my-posh"
remove_if_exists "$HOME/.config/bat"
remove_if_exists "$HOME/.config/.tmp"

if [ "$OSTYPE" == 'darwin' ]; then
    remove_if_exists "$HOME/.config/karabiner"
    remove_if_exists "$HOME/.config/ghostty"
fi

cd "$HOME/dotfiles/home" && stow . --target="$HOME"

mkdir -p $HOME/dotfiles/home/.config/.tmp
remove_if_exists "$HOME/dotfiles/zsh/.fzf-translate_history.log"
mv "$HOME/dotfiles/zsh/.fzf-translate_history.log" "$HOME/dotfiles/home/.config/.tmp/." 2>/dev/null || echo "File not found: $HOME/dotfiles/zsh/.fzf-translate_history.log"

remove_if_exists "$HOME/dotfiles/zsh/.fzf-make_history.log"
mv "$HOME/dotfiles/zsh/.fzf-make_history.log" "$HOME/dotfiles/home/.config/.tmp/." 2>/dev/null || echo "File not found: $HOME/dotfiles/zsh/.fzf-make_history.log"

remove_if_exists "$HOME/dotfiles/zsh/.docker-compose-config"
mv "$HOME/dotfiles/zsh/.docker-compose-config" "$HOME/dotfiles/home/.config/.tmp/." 2>/dev/null || echo "File not found: $HOME/dotfiles/zsh/.docker-compose-config"

remove_if_exists "$HOME/dotfiles/zsh"