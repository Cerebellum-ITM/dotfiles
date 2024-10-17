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

#* Install Docker and Docker Compose
if ! command -v docker &> /dev/null; then
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
else
    log_info "Docker is already installed"
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

if ! command -v ccze &> /dev/null; then
    log_debug "Installing ccze"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
            sudo apt-get install -y ccze
        fi
    elif [ "$os_name" = "Darwin" ]; then
        brew install ccze
    fi
else
    log_info "ccze is already installed"
fi