#!/bin/bash

if ! command -v git &> /dev/null; then
    echo "Installing git"
    sudo apt-get update
    sudo apt-get install git -y
else
    echo "git is already installed"
fi

if ! command -v fzf &> /dev/null; then
    echo "Installing fzf"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
else
    echo "fzf is already installed"
fi

mkdir -p ~/.ipython/profile_default/startup/ && cd "$_" || return 1
curl -O https://raw.githubusercontent.com/Cerebellum-ITM/dotfiles/refs/heads/main/python/ipython_config.py