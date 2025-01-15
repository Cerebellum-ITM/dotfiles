function dotfiles_update() {
    cd $HOME/dotfiles
    git pull
    ./install.sh --unattended
    history_clean
    source ~/.zshrc
    cd -
}

function dotfiles() {
    if [[ "$1" == "update" || "$1" == "-u" ]]; then
        cd $HOME/dotfiles || { echo "Failed to cd to $HOME/dotfiles"; return 1; }
        git pull || { echo "Failed to pull from git"; return 1; }
        source ~/.zshrc || { echo "Failed to source ~/.zshrc"; return 1; }
        cd - || { echo "Failed to return to previous directory"; return 1; }
    elif [[ "$1" == "install" || "$1" == "-ins" ]]; then
        ansible-playbook $HOME/dotfiles/ansible/sites.yml -i $HOME/dotfiles/ansible/inventory.ini || { echo "Ansible playbook failed"; return 1; }
    fi
}
