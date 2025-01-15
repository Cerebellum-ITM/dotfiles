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
        cd $HOME/dotfiles
        git pull
        source ~/.zshrc
        cd -
    elif [[ "$1" == "install" || "$1" == "-ins" ]]; then
        ansible-playbook  $HOME/dotfiles/ansible/sites.yml -i $HOME/dotfiles/ansible/inventory.ini
    fi
}