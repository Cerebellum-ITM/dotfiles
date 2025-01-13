#!/bin/bash

# Function to install Ansible on macOS
install_ansible_darwin() {
    echo "Installing Ansible on macOS..."
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Install Ansible using Homebrew
    brew install ansible
}

# Function to install Ansible on Amazon Linux
install_ansible_amazon() {
    echo "Installing Ansible on Amazon Linux..."
    sudo yum update -y
    sudo amazon-linux-extras install ansible2 -y
}

# Function to install Ansible on Debian
install_ansible_debian() {
    echo "Installing Ansible on Debian..."
    sudo apt update -y
    sudo apt install software-properties-common -y
    sudo add-apt-repository --yes ppa:ansible/ansible
    sudo apt update -y
    sudo apt install ansible -y
}

# Detect the operating system
OS=$(uname -s)

case "$OS" in
    Darwin)
        install_ansible_darwin
        ;;
    Linux)
        # Further check for Amazon Linux
        if [ -f /etc/system-release ]; then
            if grep -q "Amazon Linux" /etc/system-release; then
                install_ansible_amazon
            else
                # Check for Debian
                if grep -q "Debian" /etc/os-release; then
                    install_ansible_debian
                else
                    echo "Unsupported Linux distribution. Please install Ansible manually."
                    exit 1
                fi
            fi
        else
            echo "Unsupported Linux distribution. Please install Ansible manually."
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system. Please install Ansible manually."
        exit 1
        ;;
esac

echo "Ansible installation completed successfully!"