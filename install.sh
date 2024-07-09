#!/bin/bash

# Ask Y/n
function ask() {
    read -p "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

# install all dependencies
os_name="$(uname -s)"
if [ "$os_name" = "Linux" ]; then
    if ! command -v stow &> /dev/null; then
        sudo apt-get install stow
    fi
elif [ "$os_name" = "Darwin" ]; then
    if ! command -v stow &> /dev/null; then
        brew install stow
    fi
fi

if [ "$os_name" = "Linux" ]; then
    if ! command -v oh-my-posh &> /dev/null; then
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    fi
elif [ "$os_name" = "Darwin" ]; then
    if ! command -v oh-my-posh &> /dev/null; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    fi
fi

if [ "$os_name" = "Linux" ]; then
    if ! command -v fzf &> /dev/null; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
elif [ "$os_name" = "Darwin" ]; then
    if ! command -v fzf &> /dev/null; then
        brew install fzf
    fi
fi

# Check what shell is being used
SH="${HOME}/.bashrc"
ZSHRC="${HOME}/.zshrc"
if [ -f "$ZSHRC" ]; then
	SH="$ZSHRC"
fi

echo >> $SH
echo '# -------------- bartekspitza:dotfiles install ---------------' >> $SH

# Remove oh-my-zsh
if ask "Do you want to remove previous oh-my-zsh installation?"; then
    rm -f ~/.p10k.zsh
    rm -rf -- ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sh ~/.oh-my-zsh/tools/uninstall.sh -y
    rm ~/.zshrc
fi

# Ask which files should be sourced
for folder in *; do
    if [ -d "$folder" ]; then
        filename=$(basename "$folder")
        if ask "${filename}?"; then
            stow $folder
        fi
    fi
done