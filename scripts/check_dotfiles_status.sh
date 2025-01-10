#!/bin/bash

check_internet() {
    if ! ping -c 1 google.com &> /dev/null; then
        return 1
    fi
    return 0
}

SCRIPT_DIR="$(dirname "$0")"
REPO_PATH="$(realpath "$SCRIPT_DIR/..")"

cd "$REPO_PATH" || exit

#! Check for internet connectivity

if ! check_internet; then
    echo "NO"
    exit 0
fi

(git fetch origin &> /dev/null) &
REMOTE_COMMIT=$(git rev-parse origin/main)
LOCAL_COMMIT=$(git rev-parse main)

if [ "$REMOTE_COMMIT" != "$LOCAL_COMMIT" ]; then
    echo ""
else
    echo "" 
fi