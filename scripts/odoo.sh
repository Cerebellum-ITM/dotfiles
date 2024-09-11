odoo() {
    CADDYFILE_PATH="/etc/caddy/Caddyfile"

    if [ ! -f "$CADDYFILE_PATH" ]; then
        echo "No Caddyfile configured at  $(purple_underlie $CADDYFILE_PATH)"
        return 1
    fi

    if [[ "$1" == "-p" && -n "$2" ]]; then
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
        ' "$CADDYFILE_PATH")
        
        if [[ -n "$url" ]]; then
            echo "The URL for the port $(purple $port) is: $(blue_bold_underlie $url)"
        else
            echo "There is no URL for the port $(red_bold $port)"
        fi
    elif [[ "$1" == "-l" ]]; then
        cat "$CADDYFILE_PATH"
    else
        echo "List of available commands:\n Search for the URL of a port: $(green_bold '-p') $(purple_underlie '<port>'), Exmaple: $(blue_underlie 'odoo -p 8069')"
    fi
}