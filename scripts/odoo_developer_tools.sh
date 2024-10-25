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

os_name="$(uname -s)"
if [ "$os_name" = "Linux" ]; then
    distribution=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi

function ask() {
    log_warning "$1 (Y/n): "
    read -p "" resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]')
    fi

    [ "$response_lc" = "y" ]
}


#* Install Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    if ask "Do you want to install Docker?"; then
        log_debug "Installing Docker"
        if [ "$os_name" = "Linux" ]; then
            if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                sudo usermod -aG docker $USER
            fi
        elif [ "$os_name" = "Darwin" ]; then
            brew install --cask docker
        fi
        if ! command -v docker-compose &> /dev/null; then
            log_debug "Installing Docker Compose"
            if [ "$os_name" = "Linux" ]; then
                sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
            elif [ "$os_name" = "Darwin" ]; then
                brew install docker-compose
            fi
        else
            log_info "Docker Compose is already installed"
        fi
    fi
else
    log_info "Docker tools are already installed"
fi

#* Install ccze
if ! command -v ccze &> /dev/null; then
    if ask "Do you want to install ccze?"; then
        log_debug "Installing ccze"
        if [ "$os_name" = "Linux" ]; then
            if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
                sudo apt-get install -y ccze
            fi
        elif [ "$os_name" = "Darwin" ]; then
            brew install ccze
        fi
    fi
else
    log_info "ccze is already installed"
fi

#* Install Caddy
if ! command -v caddy &> /dev/null; then
    if ask "Do you want to install Caddy?"; then
        log_debug "Installing Caddy"
        if [ "$os_name" = "Linux" ]; then
            if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
                sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
                curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
                curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
                sudo apt update
                sudo apt install -y caddy
            fi
        elif [ "$os_name" = "Darwin" ]; then
            brew install caddy
        fi
    else
        log_info "Skipping Caddy installation"
    fi
else
    log_info "Caddy is already installed"
fi

#* Configure .gitconfig
if ask "Do you want to configure .gitconfig?"; then
    log_debug "Configuring .gitconfig"
    cat <<EOL > ~/.gitconfig
[user]
    name = Dev
    email = dev@dev.mx
    signingkey = 

[commit]
    gpgsign = true

[gpg]
    format = ssh
EOL
    log_info ".gitconfig has been configured"
else
    log_info "Skipping .gitconfig configuration"
fi

#* Configure .ssh/config
if ask "Do you want to configure .ssh/config?"; then
    log_debug "Configuring .ssh/config"
    mkdir -p ~/.ssh
    cat <<EOL > ~/.ssh/config
# Dev GitHub
Host github.com
    IdentityFile ~/.ssh/github.pub
EOL
    chmod 600 ~/.ssh/config
    log_info ".ssh/config has been configured"
else
    log_info "Skipping .ssh/config configuration"
fi