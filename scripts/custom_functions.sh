# shellcheck shell=bash
#* This file is dedicated to different functions that do not need a file for themselves.
function take(){
    mkdir -p "$1"
    cd "$1" || exit
}

fzf_select() {
    trap 'rm -f /tmp/initial_path' EXIT
    local directories multi_select mode new_mode
    
    multi_select=""
    mode="${1:-"path_changer"}"
    if [[ "$1" == "-m" ]]; then
        multi_select="-m"
        mode="select"
        echo $multi_select > /tmp/fzf_select_multi
    fi

    if [[ -f /tmp/fzf_select_multi ]]; then
        multi_select=$(cat /tmp/fzf_select_multi)
        rm /tmp/fzf_select_multi
    fi
    
    if [[ ! -f /tmp/initial_path ]]; then
        echo "$PWD" > /tmp/initial_path
    fi
    
    
    while true; do
        if [[ "$mode" == "select" ]]; then
            header="MODE: SELECT (Press TAB to change to PATH CHANGER) - CTRL-X (abort)"
            color="header:bright-green"
        else
            header="MODE: PATH CHANGER (Press Shift-TAB to change to SELECT) - CTRL-X (abort)"
            color="header:bright-magenta"
        fi

        selected=$(find . -maxdepth 1 -mindepth 1 -type d -o -type f 2> /dev/null | \
            awk 'BEGIN {print ".."} {print}' | fzf $multi_select \
                --height=100% --layout=reverse --border \
                --preview='[[ {} == ".." ]] && eza --tree --color=always --icons ../ || [[ -d {} ]] && eza --tree --color=always --icons {} || bat -n --color=always {}' \
                --header="$header" \
                --color="$color" \
                --bind 'ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code' \
                --bind 'tab:execute-silent(echo path_changer > /tmp/fzf_mode && echo $multi_select > /tmp/fzf_select_multi)+abort' \
                --bind 'shift-tab:execute-silent(echo select > /tmp/fzf_mode && echo $multi_select > /tmp/fzf_select_multi)+abort' \
            )
        
        if [[ -z "$selected" ]]; then
            break
        fi

        if [[ "$selected" == ".." ]]; then
            cd ..
            fzf_select "$mode" "$multi_select"
        elif [[ "$mode" == "path_changer" && -d "$selected" ]]; then
            cd "$selected" || return 1

            directories=$(find . -maxdepth 1 -type d ! -name '.')
            if [[ -n "$directories" ]]; then
                new_mode="path_changer"
            else
                new_mode="select"
            fi

            fzf_select "$new_mode" "$multi_select"
        else
            #? REMOVE?
            if [[ -n "$multi_select" ]]; then
                echo $selected
            else
                echo "$(basename "$selected")"
            fi
            initial_path=$(cat /tmp/initial_path)
            cd "$initial_path" || return 1
            rm /tmp/initial_path
        fi
        break
    done

    if [[ -f /tmp/fzf_mode ]]; then
        mode=$(cat /tmp/fzf_mode)
        rm /tmp/fzf_mode
        fzf_select "$mode" "$multi_select"
    fi
}