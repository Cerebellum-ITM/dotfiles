# shellcheck shell=bash
function dotfiles_update() {
    cd "$HOME/dotfiles" || exit
    git pull
    ./install.sh --unattended
    history_clean
    # shellcheck source=/dev/null
    source ~/.zshrc 
    cd - > /dev/null 2>&1 || exit
}

function dotfiles() {
    if [[ "$1" == "update" || "$1" == "-u" ]]; then
        gum_log_info "$(gum_yellow " ") DotFiles $(gum_blue_bold "Update")"
        gum spin --spinner dot --title "Starting the process of $(gum_blue_bold "updating") the $(git_green_underline "dotfiles") repository has begun $(git_strong_red  )" -- sleep 1
        shift
        cd "$HOME/dotfiles" || { echo "Failed to cd to $HOME/dotfiles"; return 1; }
        git stash
        git pull || { echo "Failed to pull from git"; return 1; }
        # shellcheck source=/dev/null
        source ~/.zshrc || { echo "Failed to source ~/.zshrc"; return 1; }
        cd - > /dev/null 2>&1 || { echo "Failed to return to previous directory"; return 1; }
    elif [[ "$1" == "install" || "$1" == "-ins" ]]; then
        ansible-playbook "$HOME/dotfiles/ansible/sites.yml" -i "$HOME/dotfiles/ansible/inventory.ini" || { echo "Ansible playbook failed"; return 1; }
    fi
}
