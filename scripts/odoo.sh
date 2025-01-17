# shellcheck shell=bash
CADDY_FILE_PATH="/etc/caddy/Caddyfile"

_check_for_caddy_file(){
    if [ ! -f "$CADDY_FILE_PATH" ]; then
        gum_log_warning "No Caddyfile configured at" CADDY_FILE_PATH $CADDY_FILE_PATH
        return 1
    fi
}

_create_a_changelog(){
    gum_log_info "$(gum_blue " ") $(git_strong_gray_light "Creating a ChangeLog.md file for the Odoo project.")"
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        local base_dir
        base_dir=$(pwd)

        if [ -f "$base_dir/CHANGELOG.md" ]; then
            gum_log_warning "$(gum_yellow_dark "A CHANGELOG.md file already exists in the directory... discarding task")"
            return 1
        fi
        
        touch CHANGELOG.md
        git add "CHANGELOG.md"
        git commit -m "[ADD] CHANGELOG.md: a file was added to keep track of changes in Odoo modules"
        gum_log_debug "$(git_strong_red "") The $(git_strong_red "commit") has been created $(git_green_light  "successfully")."
        gum_log_info "$(gum_cyan_dark "") $(git_strong_white_light "Task complete.")"
    else
        gun_log_fatal "$(gum_red "") $(git_strong_red_dark "There is no docker-compose file; it is most likely that this is not the parent directory.")"
    fi
}

odoo() {
    if [[ "$1" == "--tools" || "$1" == "-t" ]]; then
        cmd_options=$(echo -e "ChangeLog: Add changelog to project" | gum filter)
        if [[ $cmd_options == *'ChangeLog'* ]]; then
            _create_a_changelog
        fi
    elif [[ "$1" == "--search-odoo-port"  || "$1" == "-p" ]]; then
        if [[ ! "$2" ]]; then
            gun_log_fatal "$(gum_red "") $(git_strong_red_dark "You did not enter the port you want to search for.")"
            return 1
        fi
        _check_for_caddy_file || return 1
        port=$2
        #* Search for the port in the Caddyfile
        url=$(awk -v port="$port" '
            /reverse_proxy.*localhost:'"$port"'/ {
                if (NR > 1) {
                    match(prev, /https?:\/\/[^ ]+/)
                    print substr(prev, RSTART, RLENGTH)
                }
            }
            { prev = $0 }
        ' "$CADDY_FILE_PATH")
        
        if [[ -n "$url" ]]; then
            echo "The URL for the port $(gum_blue_dark_bold_underline "$port") is: $(gum_blue_bold_underline "$url")"
        else
            echo "There is no URL for the port $(git_strong_red "$port")"
        fi
    elif [[ "$1" == "--show-CaddyFile" || "$1" == "-sh" ]]; then
        cat "$CADDY_FILE_PATH"
    elif [[ "$1" == "--edit-CaddyFile" || "$1" == "-e" ]]; then
        code "$CADDY_FILE_PATH"
    else
        gum format -t markdown --theme="tokyo-night" < "$HOME/dotfiles/docs/function_odoo_help.md" | gum pager --soft-wrap=false
        gum confirm "Search the commands" && CONTINUE=true || CONTINUE=false
        if [[ $CONTINUE == "true" ]]; then
            local cmd_options odoo_port
            odoo_port=''
            cmd_options=$(echo -e "--search-odoo-port\n--show-CaddyFile\n--edit-CaddyFile" | gum filter)
            if [[ $cmd_options == '--search-odoo-port' ]]; then
                odoo_port=$(gum input --cursor.foreground "#FF0" \
                --prompt.foreground "#0FF" \
                --prompt "* Witch Odoo port: " \
                --placeholder "8080" \
                --width 80
                )
            fi
            odoo "$cmd_options" "$odoo_port"
        fi
    fi
}