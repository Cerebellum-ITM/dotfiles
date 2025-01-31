#!/bin/bash

check_internet() {
    if ! ping -c 1 google.com &> /dev/null; then
        return 1
    fi
    return 0
}

PROMPT=''
CURRENT_DIR=$(pwd)
IS_BLACKLISTED=false
BLACKLIST=("$HOME/dotfiles")
CURRENT_DIR_NAME=$(basename "$PWD")
PARENT_DIR=$(dirname "$CURRENT_DIR")

for DIR in "${BLACKLIST[@]}"; do
    if [[ "$CURRENT_DIR" == "$DIR" || "$CURRENT_DIR" == "$DIR/*" ]]; then
        IS_BLACKLISTED=true
        break
    fi
done


if $IS_BLACKLISTED; then
    echo "" #! Do not show anything in the prompt if we are in a directory marked on the blacklist.
else
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        if [[ "$CURRENT_DIR_NAME" == *addons* ]]; then
            if ! check_internet; then
                echo "󱛅"
                exit 0
            fi
            cd .. || return 1
            if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                (git -C "$PARENT_DIR" fetch origin &> /dev/null) &
                LOCAL_BRANCH=$(git branch --show-current)
                REMOTE_BRANCH=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)")
                REMOTE_COMMIT=$(git rev-parse "$REMOTE_BRANCH")
                LOCAL_COMMIT=$(git rev-parse "$LOCAL_BRANCH")

                if [ "$REMOTE_COMMIT" != "$LOCAL_COMMIT" ]; then
                    PROMPT+=""
                else
                    PROMPT+="" 
                fi
            fi
        fi
        echo "$PROMPT"
    else
        echo "" #! Do not show anything in the prompt if we are not in a directory that contains a git directory
    fi
fi
