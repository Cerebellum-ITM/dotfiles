# shellcheck shell=bash

gum_log_debug() {
    gum log --structured --time TimeOnly --level debug "$@"
}

gum_log_info() {
    gum log --structured --time TimeOnly --level info "$@"
}

gum_log_warning() {
    gum log --structured --time TimeOnly --level warn "$@"
}

gum_log_error() {
    gum log --structured --time TimeOnly --level error "$@"
}

gun_log_fatal() {
    gum log --structured --time TimeOnly --level fatal "$@"
}

run_and_pipe_output_to_gum_log(){
    declare -A args
    local cmd_output

    for arg in "$@"; do
        key="${arg%%=*}"     
        value="${arg#*=}"    
        args["$key"]="$value"
    done

    cmd="${args["cmd"]:-""}"
    function_log="${args["function_log"]:-""}"

    cmd_output=$($cmd 2>&1)
    echo "$cmd_output" | while IFS= read -r line; do
        $function_log "$(git_strong_gray_light "$line")"
    done
}


pipe_output_to_gum_log(){
    declare -A args

    for arg in "$@"; do
        key="${arg%%=*}"     
        value="${arg#*=}"    
        args["$key"]="$value"
    done

    cmd_output="${args["cmd_output"]:-""}"
    function_log="${args["function_log"]:-""}"

    echo "$cmd_output" | while IFS= read -r line; do
        $function_log "$(git_strong_gray_light "$line")"
    done
}