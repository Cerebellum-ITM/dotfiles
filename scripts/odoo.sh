# shellcheck shell=bash
CADDY_FILE_PATH="/etc/caddy/Caddyfile"

_check_for_caddy_file(){
    if [ ! -f "$CADDY_FILE_PATH" ]; then
        gum_log_warning "No Caddyfile configured at" CADDY_FILE_PATH $CADDY_FILE_PATH
        return 1
    fi
}


odoo() {
    if [[ "$1" == "--search-odoo-port" && -n "$2" || "$1" == "-p" && -n "$2" ]]; then
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
    elif [[ "$1" == "--show-CaddyFile" || "$1" == "-sw" ]]; then
        cat "$CADDY_FILE_PATH"
    elif [[ "$1" == "--edit-CaddyFile" || "$1" == "-c" ]]; then
        code "$CADDY_FILE_PATH"
    else
        gum format -t markdown --theme="tokyo-night" < "$HOME/dotfiles/docs/function_odoo_help.md"
        gum confirm "Search the commands" --timeout=3s && CONTINUE=true
        if [[ $CONTINUE == "true" ]]; then
            odoo_port=''
            cmd_options=$(echo -e "--search-odoo-port\n--show-CaddyFile\n--edit-CaddyFile" | gum filter)
            if [[ $cmd_options == '--search-odoo-port' ]]; then
                odoo_port=$(gum input --cursor.foreground "#FF0" \
                --prompt.foreground "#0FF" \
                --prompt "* Witch Odoo port: " \
                --placeholder "8080" \
                --width 80
                )
                odoo "$cmd_options" "$odoo_port"
            fi
        fi
    fi
}