#!/bin/bash

os_name="$(uname -s)"
if [ "$os_name" = "Linux" ]; then
    distribution=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi

if ! command -v gum &>/dev/null; then
    echo "Installing gum"
    if [ "$os_name" = "Linux" ]; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install gum
    elif [ "$os_name" = "Darwin" ]; then
        brew install gum
    fi
else
    echo "gum is already installed"
fi
# shellcheck source=/dev/null
source "$HOME"/dotfiles/tools/gum_log_functions.sh

# Ask Y/n
function ask() {
    gum_log_warning "$1 (Y/n): "
    read -p "" resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

gum_log_info "Check for dependencies"
# install all dependencies

if [ "$os_name" = "Linux" ]; then
    if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
        sudo apt-get update
    elif [ "$distribution" = "Amazon Linux" ]; then
        sudo yum update
    fi
elif [ "$os_name" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
        gum_log_debug "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
fi

if ! command -v zsh &>/dev/null; then
    gum_log_debug "Installing zsh"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
            sudo apt-get install zsh -y
        elif [ "$distribution" = "Amazon Linux" ]; then
            sudo yum install zsh -y
        fi
    elif [ "$os_name" = "Darwin" ]; then
        brew install zsh
    fi
else
    gum_log_info "zsh is already installed"
fi

if ! command -v stow &>/dev/null; then
    gum_log_debug "Installing stow"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
            sudo apt-get install stow -y
        elif [ "$distribution" = "Amazon Linux" ]; then
            wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
            tar -xzvf stow-latest.tar.gz
            cd stow-*/ || exit
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
    gum_log_info "Stow is already installed"
fi

if ! command -v oh-my-posh &>/dev/null; then
    gum_log_debug "Installing oh-my-posh"
    if [ "$os_name" = "Linux" ]; then
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    elif [ "$os_name" = "Debian GNU/Linux" ]; then
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    elif [ "$os_name" = "Darwin" ]; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    fi
else
    gum_log_info "oh-my-posh is already installed"
    gum_log_debug "Updating oh-my-posh"
    # sudo oh-my-posh upgrade --force
fi

if ! command -v fzf &>/dev/null; then
    gum_log_debug "Installing fzf"
    if [ "$os_name" = "Linux" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    elif [ "$os_name" = "Darwin" ]; then
        brew install fzf
    fi
else
    gum_log_info "fzf is already installed"
fi

if ! command -v zoxide &>/dev/null; then
    gum_log_debug "Installing zoxide"
    if [ "$os_name" = "Linux" ]; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    elif [ "$os_name" = "Darwin" ]; then
        brew install zoxide
    fi
else
    gum_log_info "zoxide is already installed"
fi

if ! command -v bat &>/dev/null; then
    gum_log_debug "Installing bat"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
            sudo apt-get install bat -y
            if ! command -v bat &>/dev/null; then
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
    BAT_MIN_VERSION="0.24.0"
    BAT_CURRENT_VERSION=$(bat --version | awk '{print $2}')
    if [ "$(printf '%s\n' "$BAT_MIN_VERSION" "$BAT_CURRENT_VERSION" | sort -V | head -n1)" != "$BAT_MIN_VERSION" ]; then
        gum_log_warning "The installed version of bat is lower than the minimum required version" CURRENT_VERSION "$BAT_CURRENT_VERSION" BAT_MIN_VERSION $BAT_MIN_VERSION
        if [ "$os_name" = "Linux" ]; then
            if [ "$distribution" = "Ubuntu" ]; then
                gum_gum_log_debug "Installing for distribution:" "$distribution"
                wget https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
                sudo dpkg -i bat_0.25.0_amd64.deb
                rm -rf bat_0.25.0_amd64.deb
            elif [ "$distribution" = "Debian GNU/Linux" ]; then
                gum_gum_log_debug "Installing for distribution:" "$distribution"
                curl -o bat.zip -L https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-aarch64-unknown-linux-gnu.tar.gz
                tar -xvf bat.zip
                mv bat-v0.24.0-x86_64-unknown-linux-musl /usr/bin/batcat
                ln -s /usr/bin/batcat/bat ~/.local/bin/bat
            elif [ "$distribution" = "Amazon Linux" ]; then
                gum_gum_log_debug "Installing for distribution:" "$distribution"
                curl -o bat.zip -L https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-unknown-linux-musl.tar.gz
                tar -xvf bat.zip
                mv bat-v0.24.0-x86_64-unknown-linux-musl /usr/bin/batcat
                ln -s /usr/bin/batcat/bat ~/.local/bin/bat
            fi
        elif [ "$os_name" = "Darwin" ]; then
            brew install bat
        fi
        gum_log_debug "bat has been updated to the latest version."
    else
        gum_log_debug "The installed version of bat ($BAT_CURRENT_VERSION) is sufficient."
    fi

    gum_log_debug "bat is already installed"
    bat cache --build
fi

if ! command -v eza &>/dev/null; then
    gum_log_debug "Installing eza"
    if [ "$os_name" = "Linux" ]; then
        sudo apt update
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    elif [ "$os_name" = "Darwin" ]; then
        brew install eza
    fi
else
    gum_log_info "eza is already installed"
    gum_log_debug "Updating eza"
    sudo eza upgrade --force
fi

if ! command -v cookiecutter &>/dev/null; then
    if command -v python3 &>/dev/null; then
        if ! command -v pip &>/dev/null; then
            gum_log_debug "pip is not installed. Installing pip."
            sudo apt-get install -y python3-pip
        fi
        gum_log_debug "Installing cookiecutter"
        if [ "$distribution" = "Debian GNU/Linux" ]; then
            sudo apt-get install -y cookiecutter
        else
            pip install cookiecutter
        fi
    else
        gum_log_error "Python3 is not installed. Please install Python3 and try again."
    fi
fi

#! Install pbcopy or xclip
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     gum_log_info "Pbcopy is included in macOS by default and does not need to be installed."
# elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
#     if command -v apt-get &> /dev/null; then
#         gum_log_info "Installing xclip and xsel for Linux (Debian/Ubuntu)"
#         sudo apt-get update
#         sudo apt-get install -y xclip xsel
#     elif command -v yum &> /dev/null; then
#         gum_log_info "Installing xclip and xsel for Linux (CentOS/RHEL)"
#         sudo yum install -y xclip xsel
#     elif command -v pacman &> /dev/null; then
#         gum_log_info "Installing xclip and xsel for Linux (Arch)"
#         sudo pacman -Syu xclip xsel
#     fi
# fi

GIT_MIN_VERSION="2.5.0"
GIT_CURRENT_VERSION=$(git --version | awk '{print $3}')
if [ "$(printf '%s\n' "$GIT_MIN_VERSION" "$GIT_CURRENT_VERSION" | sort -V | head -n1)" != "$GIT_MIN_VERSION" ]; then
    gum_log_warning "The installed version of git is lower than the minimum required version" CURRENT_VERSION "$GIT_CURRENT_VERSION" BAT_MIN_VERSION "$GIT_MIN_VERSION"
    if [ "$os_name" = "Linux" ]; then
        gum_log_debug "Installing for distribution:" "$distribution"
        sudo add-apt-repository ppa:git-core/ppa
        sudo apt update
        sudo apt install git
    elif [ "$os_name" = "Darwin" ]; then
        brew install git
    fi
    gum_log_debug "Git has been updated to the latest version."
else
    gum_log_debug "The installed version of Git is sufficient." CURRENT_VERSION "$GIT_CURRENT_VERSION"
fi

#! Check for translation dependencies
if ! command -v trans &>/dev/null; then
    gum_log_debug "Installing trans"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ]; then
            sudo apt-get install translate-shell -y
        elif [ "$distribution" = "Amazon Linux" ]; then
            sudo yum install translate-shell -y
        fi
    elif [ "$os_name" = "Darwin" ]; then
        brew install translate-shell
    fi
else
    gum_log_info "trans is already installed"
fi

#! Install delta
if ! command -v delta &>/dev/null; then
    gum_log_debug "Installing delta"
    if [ "$os_name" = "Linux" ]; then
        wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
        sudo dpkg -i git-delta_0.18.2_amd64.deb
        rm -rf git-delta_0.18.2_amd64.deb
    elif [ "$os_name" = "Darwin" ]; then
        brew install git-delta
    fi
    cat "$HOME"/dotfiles/git/delta_config.txt >>"$HOME/.gitconfig"
else
    DELTA_MIN_VERSION="0.24.0"
    GITCONFIG="$HOME/.gitconfig"
    DELTA_CONFIG="$HOME/dotfiles/git/delta_config.txt"
    DELTA_CURRENT_VERSION=$(bat --version | awk '{print $2}')
    if [ "$(printf '%s\n' "$DELTA_MIN_VERSION" "$DELTA_CURRENT_VERSION" | sort -V | head -n1)" != "$DELTA_MIN_VERSION" ]; then
        gum_log_warning "The installed version of Delta is lower than the minimum required version" DELTA_CURRENT_VERSION "$DELTA_CURRENT_VERSION" DELTA_MIN_VERSION $DELTA_MIN_VERSION
        if [ "$os_name" = "Linux" ]; then
            wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
            sudo dpkg -i git-delta_0.18.2_amd64.deb
            rm -rf git-delta_0.18.2_amd64.deb
        elif [ "$os_name" = "Darwin" ]; then
            brew install delta
        fi
        gum_log_debug "Delta has been updated to the latest version."
    else
        gum_log_debug "The installed version of Delta ($DELTA_CURRENT_VERSION) is sufficient."
    fi

    if ! grep -q "^\[delta\]" "$GITCONFIG"; then
        gum_log_warning "Delta configuration is missing"
        gum_log_debug "Adding Delta configuration"
        cat "$HOME"/dotfiles/git/delta_config.txt >>"$HOME/.gitconfig"
    fi
    gum_log_info "Delta is already installed"
fi

if ! command -v hx &>/dev/null; then
    gum_log_debug "Installing Helix"
    if [ "$os_name" = "Linux" ]; then
        curl -LO https://github.com/helix-editor/helix/releases/download/25.01.1/helix-25.01.1-x86_64-linux.tar.xz
        tar -xf helix-25.01.1-x86_64-linux.tar.xz
        cd helix-25.01.1-x86_64-linux && sudo mv -f hx /usr/local/bin/ && sudo mv -f runtime/ /usr/local/bin/
        cd .. && rm -rf helix-25.01.1-x86_64-linux && rm -rf helix-25.01.1-x86_64-linux.tar.xz
    elif [ "$os_name" = "Darwin" ]; then
        brew install helix
    fi
else
    gum_log_info "Helix is already installed"
fi

if ! command -v lazygit &>/dev/null; then
    gum_log_debug "Installing lazygit"
    if [ "$os_name" = "Linux" ]; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
    elif [ "$os_name" = "Darwin" ]; then
        brew install jesseduffield/lazygit/lazygit
    fi
else
    gum_log_info "Helix is already installed"
fi

if ! command -v atuin &>/dev/null; then
    gum_log_debug "Installing Atuin"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
    gum_log_info "Atuin is already installed"
fi

if ! command -v nvim &>/dev/null; then
    gum_log_debug "Installing nvim"
    if [ "$os_name" = "Linux" ]; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    elif [ "$os_name" = "Darwin" ]; then
        brew install neovim
    fi
else
    gum_log_info "Helix is already installed"
fi

#* Check if history files exist, if not, create them
FZF_MAKE_HISTORY_FILE="$HOME/dotfiles/home/.config/.tmp/.fzf-make_history.log"
if [ ! -f "$FZF_MAKE_HISTORY_FILE" ]; then
    touch "$FZF_MAKE_HISTORY_FILE"
    gum_log_info "Created history file for fzf-make"
fi

#* check if history files exist, if not, create them
FZF_TRANSLATE_HISTORY_FILE="$HOME/dotfiles/home/.config/.tmp/.fzf-translate_history.log"
if [ ! -f "$FZF_TRANSLATE_HISTORY_FILE" ]; then
    touch "$FZF_TRANSLATE_HISTORY_FILE"
    gum_log_info "Created history file for fzf-translate"
fi

#* check docker-compose config file exists, if not, create it
DOCKER_COMPOSE_CONFIG_FILE="$HOME/dotfiles/home/.config/.tmp/.docker-compose-config"
if [ ! -f "$DOCKER_COMPOSE_CONFIG_FILE" ]; then
    touch "$DOCKER_COMPOSE_CONFIG_FILE"
    echo "export DOCKER_COMPOSE_CMD='docker compose'" >"$DOCKER_COMPOSE_CONFIG_FILE"
    gum_log_info "Created docker-compose config file"
fi

UNATTENDED_INSTALLATION=false
if [ "$1" == "--unattended" ]; then
    UNATTENDED_INSTALLATION=true
fi

if [ "$UNATTENDED_INSTALLATION" == false ]; then
    # Remove oh-my-zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        if ask "Do you want to remove previous oh-my-zsh installation?"; then
            gum_log_debug "Removing oh-my-zsh"
            rm -f ~/.p10k.zsh
            rm -rf -- "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
            sh ~/.oh-my-zsh/tools/uninstall.sh -y
            rm -rf ~/.oh-my-zsh
            rm ~/.zshrc
        fi
    else
        gum_log_info "oh-my-zsh is not installed, skipping removal."
    fi

    gum_log_info '# -------------- dotfiles install ---------------'
    # list of folders to exclude
    exclude_folders=("scripts" "templates" "git")

    # Source all files
    gum_log_info "Which files should be sourced?"
    for folder in *; do
        if [ -d "$folder" ]; then
            exclude=false
            for exclude_folder in "${exclude_folders[@]}"; do
                if [[ "$folder" == "$exclude_folder" ]]; then
                    exclude=true
                    break
                fi
            done
            if [ "$exclude" = false ]; then
                filename=$(basename "$folder")
                if ask "${filename}?"; then
                    stow -R "$folder"
                fi
            fi
        fi
    done
fi

gum_log_info "Installation completed. Please restart your terminal."
gum_log_info "Run the following command:\nsource ~/.zshrc"
