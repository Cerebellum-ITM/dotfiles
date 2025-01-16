# shellcheck shell=bash
#* This file is dedicated to different functions that do not need a file for themselves.
function take(){
    mkdir -p "$1"
    cd "$1" || exit
}