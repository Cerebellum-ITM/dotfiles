# shellcheck shell=bash
DOTFILES_STATE_DIR="$HOME/.cache/dotfiles"
DOTFILES_STATE_FILE="$DOTFILES_STATE_DIR/state"

function _dotfiles_state_get() {
    local key="$1"
    [[ -f "$DOTFILES_STATE_FILE" ]] || return 0
    grep -E "^${key}=" "$DOTFILES_STATE_FILE" 2>/dev/null | tail -n1 | cut -d= -f2-
}

function _dotfiles_state_set() {
    local key="$1" value="$2" tmp
    mkdir -p "$DOTFILES_STATE_DIR"
    touch "$DOTFILES_STATE_FILE"
    tmp=$(mktemp)
    grep -vE "^${key}=" "$DOTFILES_STATE_FILE" >"$tmp" 2>/dev/null
    echo "${key}=${value}" >>"$tmp"
    mv "$tmp" "$DOTFILES_STATE_FILE"
}

function _dotfiles_latest_release_tag() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null |
        grep '"tag_name":' | head -n1 | sed -E 's/.*"tag_name": "([^"]+)".*/\1/'
}

function _dotfiles_update_cli() {
    local repo="$1" binary="$2" force="${3:-false}" state_key="cli_${2}_tag" latest stored
    latest=$(_dotfiles_latest_release_tag "$repo")
    if [[ -z "$latest" ]]; then
        gum_log_warning "$(gum_yellow_dark "󰀪") Could not fetch latest release for $(gum_yellow_bold "$binary")"
        return 0
    fi
    stored=$(_dotfiles_state_get "$state_key")
    if [[ "$force" != "true" ]] && [[ "$stored" == "$latest" ]] && command -v "$binary" &>/dev/null; then
        gum_log_info "$(git_strong_white_dark " ") $binary $(gum_green "up to date") ($latest)"
        return 0
    fi
    if [[ "$force" == "true" ]]; then
        gum_log_info "$(git_strong_white_dark " ") $binary: $(gum_yellow_bold "force reinstall") -> $(gum_green "$latest")"
    else
        gum_log_info "$(git_strong_white_dark " ") $binary: $(gum_yellow_bold "${stored:-none}") -> $(gum_green "$latest")"
    fi
    if "$HOME/dotfiles/tools/install_github_release.sh" "$repo" "$binary"; then
        _dotfiles_state_set "$state_key" "$latest"
        gum_log_info "$(git_strong_white_dark " ") $binary update $(gum_green "complete")"
    else
        gum_log_warning "$(gum_red "") $binary update $(gum_yellow_bold "failed")"
    fi
}

function dotfiles_update() {
    cd "$HOME/dotfiles" || exit
    git pull
    ./install.sh --unattended
    history_clean
    # shellcheck source=/dev/null
    source ~/.zshrc
    cd - >/dev/null 2>&1 || exit
}

function s() {
    local zshrc="$HOME/.zshrc"
    local current force=false
    if [[ "$1" == "-f" || "$1" == "--force" ]]; then
        force=true
    fi
    if [[ ! -f "$zshrc" ]]; then
        gum_log_warning "$(gum_red "") $zshrc not found"
        return 1
    fi
    current=$(shasum "$zshrc" | awk '{print $1}')
    if [[ "$force" != "true" ]] && [[ "$current" == "$_S_ZSHRC_HASH" ]]; then
        printf '\n%.0s' {1..100}
        gum_log_info "$(git_strong_white_dark " ") .zshrc $(gum_green "unchanged"); skipping source"
        return 0
    fi
    # shellcheck source=/dev/null
    set --
    source "$zshrc" && export _S_ZSHRC_HASH="$current"
    gum_log_info "$(git_strong_white_dark " ") .zshrc $(gum_green "reloaded")"
}

function dotfiles() {
    if [[ "$1" == "update" || "$1" == "-u" ]]; then
        shift
        local stash_output stash_message pull_output local_head remote_head repo_changed
        repo_changed=false
        gum_log_info "$(git_strong_white_dark " ") dotfiles $(git_green "Update")"
        gum spin --spinner dot --title "Starting the process of $(gum_blue_bold "updating") the $(git_strong_white_dark "dotfiles") repository has begun $(git_strong_white_dark )" -- sleep 1
        cd "$HOME/dotfiles" || {
            echo "Failed to cd to $HOME/dotfiles"
            return 1
        }

        gum spin --spinner dot --title "$(gum_blue_bold "Fetching") remote changes..." -- git fetch --quiet
        local_head=$(git rev-parse HEAD 2>/dev/null)
        remote_head=$(git rev-parse '@{u}' 2>/dev/null)

        if [[ -z "$remote_head" ]]; then
            gum_log_warning "$(gum_yellow_dark "󰀪") No upstream configured; skipping repo update check"
        elif [[ "$local_head" == "$remote_head" ]]; then
            gum_log_info "$(git_strong_white_dark " ") dotfiles repo $(gum_green "already up to date")"
        else
            repo_changed=true
            stash_output=$(git stash 2>&1)
            if [[ "$stash_output" != *"No local changes to save"* ]]; then
                stash_message=$(git stash list -1)
                gum_log_warning "$(gum_green "󱣫") There were $(gum_yellow_bold "changes") in the repository; these can be found in $stash_message"
            else
                gum_log_info "No local $(gum_yellow_bold "changes") to save."
            fi
            pull_output=$(git pull 2>&1)
            if [[ "$pull_output" == *"Already up to date"* ]]; then
                pipe_output_to_gum_log "cmd_output=$pull_output" "function_log=gum_log_debug"
            elif [[ "$pull_output" == *"error"* || "$pull_output" == *"conflict"* ]]; then
                gum_log_warning "$(gum_green "") $(gum_yellow_dark "Divergence detected; retrying with git reset.")"
                git reset --hard HEAD~1
                pull_output=$(git pull 2>&1)
                pipe_output_to_gum_log "cmd_output=$pull_output" "function_log=gum_log_debug"
                gum_log_info "$(gum_red "") $(gum_yellow_bold "New") code download completed"
            else
                pipe_output_to_gum_log "cmd_output=$pull_output" "function_log=gum_log_debug"
                gum_log_info "$(gum_green "") $(gum_yellow_bold "New") code download completed"
            fi
        fi

        _dotfiles_update_cli "Cerebellum-ITM/CommitCraftReborn" "commitcraft"
        _dotfiles_update_cli "Cerebellum-ITM/cast" "cast"

        if [[ "$repo_changed" == 'true' ]]; then
            # shellcheck source=/dev/null
            source ~/.zshrc || {
                echo "Failed to source ~/.zshrc"
                return 1
            }
        fi
        cd - >/dev/null 2>&1 || {
            echo "Failed to return to previous directory"
            return 1
        }
        gum_log_info "$(git_strong_white_dark " ") dotfiles update $(gum_green "complete")"
    elif [[ "$1" == "force-cli" || "$1" == "-fc" ]]; then
        shift
        local -a cli_options=("commitcraft" "cast")
        local -A cli_repos=(
            [commitcraft]="Cerebellum-ITM/CommitCraftReborn"
            [cast]="Cerebellum-ITM/cast"
        )
        local selection
        selection=$(printf '%s\n' "${cli_options[@]}" | gum choose \
            --no-limit \
            --header "Select CLI tools to force reinstall (space to toggle, enter to confirm)" \
            --cursor-prefix "[ ] " \
            --selected-prefix "[x] " \
            --unselected-prefix "[ ] ")
        if [[ -z "$selection" ]]; then
            gum_log_info "$(git_strong_white_dark " ") No CLI selected; $(gum_yellow_bold "aborting")"
            return 0
        fi
        gum_log_info "$(git_strong_white_dark " ") dotfiles $(git_green "Force CLI reinstall")"
        local cli
        while IFS= read -r cli; do
            [[ -z "$cli" ]] && continue
            _dotfiles_update_cli "${cli_repos[$cli]}" "$cli" "true"
        done <<<"$selection"
        gum_log_info "$(git_strong_white_dark " ") force-cli $(gum_green "complete")"
    elif [[ "$1" == "install" || "$1" == "-ins" ]]; then
        ansible-playbook "$HOME/dotfiles/ansible/sites.yml" -i "$HOME/dotfiles/ansible/inventory.ini" || {
            echo "Ansible playbook failed"
            return 1
        }
    fi
}
