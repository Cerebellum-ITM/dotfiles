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

log_info "Check for dependencies"
# install all dependencies
os_name="$(uname -s)"
if [ "$os_name" = "Linux" ]; then
    distribution=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi


if [ "$os_name" = "Linux" ]; then    
    if [ "$distribution" = "Ubuntu" ]; then
        sudo apt-get update
    elif [ "$distribution" = "Amazon Linux" ]; then
        sudo yum update
    fi
    if ["$distribution" = "Darwin"]; then
        if ! command -v brew &> /dev/null; then
            log_debug "Installing Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew update
    fi
fi

if ! command -v zsh &> /dev/null; then
    log_debug "Installing zsh"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ]; then
            sudo apt-get install zsh -y
        elif [ "$distribution" = "Amazon Linux" ]; then
            sudo yum install zsh -y
        fi
    elif [ "$os_name" = "Darwin" ]; then
        brew install zsh
    fi
else
    log_info "zsh is already installed"
fi

if ! command -v stow &> /dev/null; then
    log_debug "Installing stow"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ]; then
            sudo apt-get install stow -y
        elif [ "$distribution" = "Amazon Linux" ]; then
            wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
            tar -xzvf stow-latest.tar.gz
            cd stow-*/
            ./configure
            make
            sudo make install
            sudo yum install perl-File-Copy
            sudo yum install perl-core
        fi

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

if ! command -v tree &> /dev/null; then
    log_debug "Installing tree"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ]; then
            sudo apt-get install tree -y
        elif [ "$distribution" = "Amazon Linux" ]; then
            sudo yum install tree -y
        fi
    elif [ "$os_name" = "Darwin" ]; then
        brew install tree
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
        if [ "$distribution" = "Ubuntu" ]; then
            sudo apt-get install bat -y
            if ! command -v bat &> /dev/null; then
                mkdir -p ~/.local/bin
                ln -s /usr/bin/batcat ~/.local/bin/bat
            fi
        elif [ "$distribution" = "Amazon Linux" ]; then
            sudo yum install tar
            curl -o bat.zip -L https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz
            tar -xvf bat.zip
            mv bat-v0.24.0-x86_64-unknown-linux-musl /usr/bin/batcat
            ln -s /usr/bin/batcat/bat ~/.local/bin/bat 
        fi
    elif [ "$os_name" = "Darwin" ]; then
        brew install bat
    fi
else
    log_info "bat is already installed"
fi

if ! command -v cookiecutter &> /dev/null; then
    if command -v python3 &> /dev/null; then
        if ! command -v pip &> /dev/null; then
            log_debug "pip is not installed. Installing pip."
            sudo apt-get install -y python3-pip
        fi
        log_debug "Installing cookiecutter"
        pip install cookiecutter
    else
        log_error "Python3 is not installed. Please install Python3 and try again."
    fi
fi

FZF_MAKE_HISTORY_FILE="$HOME/dotfiles/zsh/.fzf-make_history.log"

# Verificar si el archivo de historial existe, si no, crearlo
if [ ! -f "$FZF_MAKE_HISTORY_FILE" ]; then
    touch "$FZF_MAKE_HISTORY_FILE"
    log_info "Created history file for fzf-make"
fi


UNATTENDED_INSTALLATION=false
if [ "$1" == "--unattended" ]; then
    UNATTENDED_INSTALLATION=true
fi

if [ "$UNATTENDED_INSTALLATION" == false ]; then
    # Remove oh-my-zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        if ask "Do you want to remove previous oh-my-zsh installation?"; then
            log_debug "Removing oh-my-zsh"
            rm -f ~/.p10k.zsh
            rm -rf -- ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            sh ~/.oh-my-zsh/tools/uninstall.sh -y
            rm -rf ~/.oh-my-zsh
            rm ~/.zshrc
        fi
    else
        log_info "oh-my-zsh is not installed, skipping removal."
    fi

    log_info '# -------------- dotfiles install ---------------'
    # list of folders to exclude
    exclude_folders=("scripts" "templates")

    # Source all files
    log_info "Which files should be sourced?"
    for folder in *; do
        if [ -d "$folder" ]; then
            if [[ ! " ${exclude_folders[@]} " =~ " ${folder} " ]]; then
                filename=$(basename "$folder")
                if ask "${filename}?"; then
                    stow -R "$folder"
                fi
            fi
        fi
    done
fi

log_info "Installation completed. Please restart your terminal."
log_info "Run the following command:\nsource ~/.zshrc"