# shellcheck shell=bash
function dotfiles_update() {
    cd "$HOME/dotfiles" || exit
    git pull
    ./install.sh --unattended
    history_clean
    # shellcheck source=/dev/null
    source ~/.zshrc
    cd - >/dev/null 2>&1 || exit
}

function dotfiles() {
    if [[ "$1" == "update" || "$1" == "-u" ]]; then
        shift
        local stash_output stash_message pull_output pull_successful
        pull_successful=false
        gum_log_info "$(git_strong_white_dark " ") dotfiles $(git_green "Update")"
        gum spin --spinner dot --title "Starting the process of $(gum_blue_bold "updating") the $(git_strong_white_dark "dotfiles") repository has begun $(git_strong_white_dark )" -- sleep 1
        cd "$HOME/dotfiles" || {
            echo "Failed to cd to $HOME/dotfiles"
            return 1
        }
        stash_output=$(git stash 2>&1)
        if [[ "$stash_output" != *"No local changes to save"* ]]; then
            stash_message=$(git stash list -1)
            gum_log_warning "$(gum_green "󱣫") There were $(gum_yellow_bold "changes") in the repository; these can be found in $stash_message"
        else
            gum_log_info "No local $(gum_yellow_bold "changes") to save."
        fi
        pull_output=$(git pull 2>&1)
        if [[ "$pull_output" != *"Already up to date"* ]]; then
            pull_successful=true
            pipe_output_to_gum_log "cmd_output=$pull_output" "function_log=gum_log_debug"
            gum_log_info "$(gum_green "") $(gum_yellow_bold "New") code download completed"
        fi

        if [[ "$pull_successful" == 'false' ]]; then
            gum_log_warning "$(gum_green "") $(gum_yellow_dark "It seems that there is a divergence when trying again using git reset.")"
            git reset --hard HEAD~1
            pull_output=$(git pull 2>&1)
            pipe_output_to_gum_log "cmd_output=$pull_output" "function_log=gum_log_debug"
            gum_log_info "$(gum_red "") $(gum_yellow_bold "New") code download completed"
        fi

        # shellcheck source=/dev/null
        "$HOME/dotfiles/tools/install_commitCraft.sh"
        # shellcheck source=/dev/null
        source ~/.zshrc || {
            echo "Failed to source ~/.zshrc"
            return 1
        }
        cd - >/dev/null 2>&1 || {
            echo "Failed to return to previous directory"
            return 1
        }
        gum_log_info "$(git_strong_white_dark " ") dotfiles update $(gum_green "complete")"
    elif [[ "$1" == "install" || "$1" == "-ins" ]]; then
        ansible-playbook "$HOME/dotfiles/ansible/sites.yml" -i "$HOME/dotfiles/ansible/inventory.ini" || {
            echo "Ansible playbook failed"
            return 1
        }
    fi
}
