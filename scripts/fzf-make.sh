# shellcheck shell=bash
working_dir=""
FZF_MAKE_HISTORY_FILE="$HOME/dotfiles/home/.config/.tmp/.fzf-make_history.log"

_check_fzf_make_exit_code() {
    if [ -f /tmp/fzf_makefile_exit_code ] && [ "$(cat /tmp/fzf_makefile_exit_code)" -eq 130 ]; then
        gun_log_fatal "Process aborted by the $(git_strong_white "user")"
        rm /tmp/fzf_makefile_exit_code
        return 1
    fi
}

check_makefile() {
    #* Check for Makefile in the current directory
    if [ -f Makefile ]; then
        working_dir="$(pwd)"
    #* Check for Makefile in the parent directory
    elif [ -f "../Makefile" ]; then
        working_dir="$(cd .. && pwd)"
    else
        gum_log_warning "No Makefile found in current or parent directory"
        return 1
    fi
}

_check_odoo_env() {
    if grep -qi "odoo" "$working_dir/docker-compose.yml"; then
        echo "true"
    else
        echo "false"
    fi

}

_fzf_make_gui() {
    fzf-tmux --ansi -m -p80%,60% -- \
        --layout=reverse --multi --height=100% --min-height=20 --border \
        --border-label-pos=2 \
        --bind 'ctrl-x:abort+execute:echo 130 > /tmp/fzf_makefile_exit_code' \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,80%,border-left' \
        --header='Select the commands to run' \
        --preview="awk '/^{}[[:space:]]*:/ {flag=1; next} /^[^[:space:]]+:/ {flag=0} flag && /^[[:space:]]/' $working_dir/Makefile | sed 's/^\t//' | bat --style='${BAT_STYLE:-full}' --color=always --paging=always --pager='less -FRX' --language=sh"
}

log_history() {
    local selection="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $working_dir - $selection" >>"$FZF_MAKE_HISTORY_FILE"
}

_function_list() {
    check_makefile || return 1
    local selected_commands
    selected_commands=$(grep -E '^[^[:space:]]+:' "$working_dir/Makefile" | grep -v '^.PHONY' | cut -d: -f1 | _fzf_make_gui)
    _check_fzf_make_exit_code || return 1
    execute_commands "$selected_commands"
}

_view_history() {
    local selected_history
    check_makefile || return 1
    if [ ! -f "$FZF_MAKE_HISTORY_FILE" ]; then
        gum_log_warning "No history file found."
        return 1
    fi

    selected_history=$(
        grep " - $working_dir -" "$FZF_MAKE_HISTORY_FILE" |
            awk -F' - ' '{print $1 " - " $3}' |
            sort -rk1,1 |
            fzf --layout=reverse --ansi --preview="echo {} | awk -F' - ' '{print \$2}' | tr ', ' '\n' | \
        while read cmd; do awk '/^'\"\$cmd\"'[[:space:]]*:/ {flag=1; next} /^[^[:space:]]+:/ {flag=0} flag && /^[[:space:]]/' $working_dir/Makefile | sed 's/^\t//'; done | bat --style='${BAT_STYLE:-full}' --color=always --paging=always --pager='less -FRX' --language=sh" \
                --preview-window=down:60%:wrap
    )
    _check_fzf_make_exit_code || return 1
    execute_commands "$(echo "$selected_history" | awk -F' - ' '{print $2}' | sed 's/ *, */,/g' | tr ',' '\n')"
}

execute_commands() {
    local selected_commands target args
    selected_commands="$1"
    if [ -n "$selected_commands" ]; then
        local original_ifs="$IFS"
        IFS=$'\n' commands_array=()
        while IFS= read -r line; do
            commands_array+=("$line")
        done <<<"$selected_commands"
        IFS="$original_ifs"

        local history_entry=""

        for cmd in "${commands_array[@]}"; do
            history_entry+="$cmd, "
        done

        history_entry="${history_entry%, }"
        log_history "$history_entry"

        for cmd in "${commands_array[@]}"; do
            target=$(echo "$cmd" | awk '{print $1}') #! The first element will always be the function to be executed
            args=$(echo "$cmd" | cut -d' ' -f2-)
            if [[ -z "$args" ]]; then
                make -C "$working_dir" "$target"
            else
                eval make -C "$working_dir" "$target" "$args"
            fi
        done
    fi
}

_select_odoo_module() {
    local dir subdir return_full_path="${1:-false}"
    #* Find directories containing "addon", ignoring those in .git
    dir=$(cd "$working_dir" && find . -type d -name '*addon*' -not -path '*/.git/*' -print | fzf --header="Select a directory containing 'addon' (press Ctrl+C to cancel)" \
        --prompt="Select a directory or press Ctrl+Z to include any directory: " \
        --preview="eza --tree --color=always --icons {} | head -200" \
        --bind 'ctrl-x:abort+execute:echo 130 > /tmp/fzf_makefile_exit_code' \
        --bind "ctrl-z:execute(cd $working_dir && fzf --header='Select any directory' --preview='eza --tree --color=always --icons {} | head -200' < <(find . -type d -not -path '*/.git/*'))")
    _check_fzf_make_exit_code || return 1
    #* Check if a directory was selected
    if [[ -z "$dir" ]]; then
        echo "No directory selected."
        return 1
    fi

    #* List subdirectories in the selected directory
    subdir=$(cd "$working_dir" && find "$dir" -mindepth 1 -maxdepth 1 -type d | fzf --header="Select a subdirectory in '$dir'" --preview='eza --tree --color=always --icons {} | head -200' --bind 'ctrl-x:abort+execute:echo 130 > /tmp/fzf_makefile_exit_code')
    _check_fzf_make_exit_code || return 1
    #* Check if a subdirectory was selected
    if [[ -z "$subdir" ]]; then
        echo "No subdirectory selected."
        return 1
    fi
    if [[ "$return_full_path" == "true" ]]; then
        echo "$subdir"
    else
        #* returns only the name of the addon
        basename "$subdir"
    fi

}

_update_odoo_module() {
    subdir=$(_select_odoo_module)

    #* Add a history entry
    local history_entry=""
    history_entry+="update_module module_name=$subdir"
    history_entry="${history_entry%, }"
    log_history "$history_entry"
    cd "$working_dir" && make update_module module_name="$subdir" | grep -v "Nothing to be done for"
}

_update_odoo_translation() {
    subdir=$(_select_odoo_module)

    #* Add a history entry
    local history_entry=""
    history_entry+="update_odoo_translation module_name=$subdir"
    history_entry="${history_entry%, }"
    log_history "$history_entry"
    cd "$working_dir" && make update_odoo_translation module_name="$subdir" | grep -v "Nothing to be done for"
}

_export_odoo_translation_module() {
    FULL_PATH=$(_select_odoo_module "true")
    subdir=$(basename "$FULL_PATH")
    repository_dir_path=$(basename "$(dirname "$FULL_PATH")")
    #* Add a history entry
    local history_entry=""
    history_entry+="export_odoo_translation module_name=$subdir module_path=$repository_dir_path"
    history_entry="${history_entry%, }"
    log_history "$history_entry"
    cd "$working_dir" && make export_odoo_translation module_name="$subdir" module_path="$repository_dir_path" | grep -v "Nothing to be done for"
}

select_a_option() {
    check_makefile || return 1
    local choice options
    options=("View history" "Select commands")
    if [[ $(_check_odoo_env) == 'true' ]]; then
        options=("View history" "Update Odoo Module" "Export Odoo translation" "Update Odoo translation" "Select commands")
    fi
    choice=$(printf "%s\n" "${options[@]}" | fzf --ansi --height=100% --preview-window='right,70%,border-left' --border --header="Choose action: 'w' for command selection, 's' for history" --preview="bat $working_dir/Makefile --style='${BAT_STYLE:-full}' --color=always" --cycle --bind 'ctrl-x:abort+execute:echo 130 > /tmp/fzf_makefile_exit_code')
    _check_fzf_make_exit_code || return 1
    if [[ "$choice" == "Select commands" ]]; then
        _function_list
    elif [[ "$choice" == "View history" ]]; then
        _view_history
    elif [[ "$choice" == "Update Odoo translation" ]]; then
        _update_odoo_translation
    elif [[ "$choice" == "Export Odoo translation" ]]; then
        _export_odoo_translation_module
    elif [[ "$choice" == "Update Odoo Module" ]]; then
        _update_odoo_module
    fi
}

_update_makefile() {
    local MAKEFILE_PATH TEMP_FILE NEW_MAKEFILE_PATH
    check_makefile || return 1
    MAKEFILE_PATH="./Makefile"
    TEMP_FILE="/tmp/Makefile_tmp"
    NEW_MAKEFILE_PATH="$HOME/dotfiles/templates/odoo/makefile_template/Makefile"
    awk '/^init:|# Start local instance/ { exit } { print }' "$MAKEFILE_PATH" >"$TEMP_FILE"
    awk '/^init:|# Start local instance/ { found=1; print; next } found { print }' "$NEW_MAKEFILE_PATH" >>"$TEMP_FILE"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' -e "s/{{ cookiecutter.docker_compose_cmd }}/$DOCKER_COMPOSE_CMD/g" \
            "$TEMP_FILE"
    else
        sed -i -e "s/{{ cookiecutter.docker_compose_cmd }}/$DOCKER_COMPOSE_CMD/g" \
            "$TEMP_FILE"
    fi

    cp -f $TEMP_FILE $MAKEFILE_PATH
}

fzf-make() {
    if [[ "$1" == "repeat" || "$1" == "-r" ]]; then
        check_makefile || return 1
        execute_commands "$(grep "$working_dir" "$FZF_MAKE_HISTORY_FILE" | sort -r | awk -F ' - ' '{print $3}' | head -n 1 | sed 's/ *, */,/g' | tr ',' '\n')"
    elif [[ "$1" == "-edit" || "$1" == "-e" ]]; then
        check_makefile || return 1
        if command -v vim &>/dev/null; then
            vim "$working_dir/Makefile"
        elif command -v nano &>/dev/null; then
            nano "$working_dir/Makefile"
        else
            gum_log_warning "The command code or nano is not available in the shell."
        fi
    elif [[ "$1" == "update" || "$1" == "-u" ]]; then
        _update_makefile
    elif [[ "$1" == "help" || "$1" == "-h" ]]; then
        printf "List of available commands:\n- repeat or -r"
    else
        select_a_option
    fi
}
