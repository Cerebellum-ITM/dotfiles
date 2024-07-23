#!/bin/bash

# print colored logs
log_info() {
    echo -e "\033[32m$1\033[0m"
}

log_warning() {
    echo -e "\033[33m$1\033[0m"
}

log_error() {
    echo -e "\033[31m$1\033[0m"
}

log_debug() {
    echo -e "\033[36m$1\033[0m"
}

# Ask Y/n
function ask() {
    log_warning "$1 (Y/n): "
    read -p "" resp
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
    sudo apt-get update
fi

if ! command -v stow &> /dev/null; then
    log_debug "Installing stow"
    if [ "$os_name" = "Linux" ]; then
        sudo apt-get install stow
    elif [ "$os_name" = "Darwin" ]; then
        brew install stow
    fi
else
    log_info "Stow is already installed"
fi

if ! command -v oh-my-posh &> /dev/null; then
    log_debug "Installing oh-my-posh"
    if [ "$os_name" = "Linux" ]; then
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    elif [ "$os_name" = "Darwin" ]; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    fi
else
    log_info "oh-my-posh is already installed"
fi

if ! command -v fzf &> /dev/null; then
    log_debug "Installing fzf"
    if [ "$os_name" = "Linux" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    elif [ "$os_name" = "Darwin" ]; then
        brew install fzf
    fi
else
    log_info "fzf is already installed"
fi

if ! command -v zoxide &> /dev/null; then
    log_debug "Installing zoxide"
    if [ "$os_name" = "Linux" ]; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    elif [ "$os_name" = "Darwin" ]; then
        brew install zoxide
    fi
else
    log_info "zoxide is already installed"
fi

if ! command -v bat &> /dev/null; then
    log_debug "Installing bat"
    if [ "$os_name" = "Linux" ]; then
        sudo apt-get install bat
    elif [ "$os_name" = "Darwin" ]; then
        brew install bat
    fi
else
    log_info "bat is already installed"
fi


# Check what shell is being used
SH="${HOME}/.bashrc"
ZSHRC="${HOME}/.zshrc"
if [ -f "$ZSHRC" ]; then
	SH="$ZSHRC"
fi

echo >> $SH
log_info '# -------------- bartekspitza:dotfiles install ---------------'

# Remove oh-my-zsh
if ask "Do you want to remove previous oh-my-zsh installation?"; then
    log_debug "Removing oh-my-zsh"
    rm -f ~/.p10k.zsh
    rm -rf -- ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sh ~/.oh-my-zsh/tools/uninstall.sh -y
    rm ~/.zshrc
fi

# Ask which files should be sourced
log_info "Which files should be sourced?"
for folder in *; do
    if [ -d "$folder" ]; then
        filename=$(basename "$folder")
        if ask "${filename}?"; then
            stow -R $folder
        fi
    fi
done

log_info "Installation completed. Please restart your terminal."
log_info "Run the following command:\nsource ~/.zshrc"