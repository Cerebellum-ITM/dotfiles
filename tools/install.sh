#!/bin/bash

source "$HOME/dotfiles/tools/log_functions.sh"

# Function to install Ansible on macOS
install_ansible_darwin() {
    log_info "Installing Ansible on macOS..."
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
        log_info "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Install Ansible using Homebrew
    brew install ansible
}

# Function to install Ansible on Amazon Linux
install_ansible_amazon() {
    log_info "Installing Ansible on Amazon Linux..."
    sudo yum update -y
    sudo amazon-linux-extras install ansible2 -y
}

# Function to install Ansible on Debian
install_ansible_debian() {
    log_info "Installing Ansible on Debian..."
    sudo apt update
    sudo apt install pipx
    pipx ensurepath
    sudo pipx ensurepath --global
    pipx install --include-deps ansible
}

# Detect the operating system
os_name="$(uname -s)"
if [ "$os_name" = "Linux" ]; then
    distribution=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi

if ! command -v ansible &> /dev/null; then
    log_debug "Installing Ansible"
    if [ "$os_name" = "Linux" ]; then
        if [ "$distribution" = "Ubuntu" ] || [ "$distribution" = "Debian GNU/Linux" ]; then
            install_ansible_debian
        elif [ "$distribution" = "Amazon Linux" ]; then
            install_ansible_amazon
        fi
    elif [ "$os_name" = "Darwin" ]; then
        install_ansible_darwin
    fi
else
    log_info "bat is already installed"
fi

log_info "Ansible installation completed successfully!"