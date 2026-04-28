#!/usr/bin/env bash
# Unified repo status check for oh-my-posh prompt.
# Modes:
#   current   compare $PWD against its upstream
#   parent    when $PWD matches *addons*, compare its parent against upstream; else silent
#   dotfiles  always compare $HOME/dotfiles against origin/main
#
# Output (single char): "" in sync, "󰊢" out of sync, "󱛅" stale (no successful fetch recently).

set -u
export GIT_OPTIONAL_LOCKS=0
export GIT_TERMINAL_PROMPT=0

MODE="${1:-current}"

FETCH_THROTTLE=300   # don't refetch more often than every 5 min
STALE_AFTER=600      # if last successful fetch >10 min ago, consider data stale

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-posh-repo-status"
mkdir -p "$CACHE_DIR" 2>/dev/null

mtime() {
    if [ -f "$1" ]; then
        if stat -f %m "$1" 2>/dev/null; then return; fi
        stat -c %Y "$1" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

resolve_repo() {
    case "$MODE" in
        dotfiles)
            echo "$HOME/dotfiles"
            ;;
        parent)
            case "$(basename "$PWD")" in
                *addons*) echo "$(dirname "$PWD")" ;;
                *) return 1 ;;
            esac
            ;;
        current|*)
            echo "$PWD"
            ;;
    esac
}

REPO="$(resolve_repo)" || exit 0
[ -n "$REPO" ] || exit 0

git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Per-repo marker files for throttling and staleness.
SLUG="$(printf '%s' "$REPO" | tr '/ ' '__')"
ATTEMPT_FILE="$CACHE_DIR/$SLUG.attempt"
SUCCESS_FILE="$CACHE_DIR/$SLUG.success"

NOW=$(date +%s)
LAST_ATTEMPT=$(mtime "$ATTEMPT_FILE")

if [ $((NOW - LAST_ATTEMPT)) -ge "$FETCH_THROTTLE" ]; then
    touch "$ATTEMPT_FILE"
    (
        if git -C "$REPO" fetch --quiet origin >/dev/null 2>&1; then
            touch "$SUCCESS_FILE"
        fi
    ) >/dev/null 2>&1 &
    disown 2>/dev/null || true
fi

# Decide upstream ref based on mode.
if [ "$MODE" = "dotfiles" ]; then
    UPSTREAM="origin/main"
else
    UPSTREAM="@{u}"
fi

COUNTS=$(git -C "$REPO" rev-list --left-right --count "HEAD...$UPSTREAM" 2>/dev/null) || {
    echo ""
    exit 0
}

# Staleness only matters if we've never had a successful fetch, or it's old.
LAST_SUCCESS=$(mtime "$SUCCESS_FILE")
if [ "$LAST_SUCCESS" = "0" ] || [ $((NOW - LAST_SUCCESS)) -gt "$STALE_AFTER" ]; then
    echo "󱛅"
    exit 0
fi

AHEAD="${COUNTS%%[[:space:]]*}"
BEHIND="${COUNTS##*[[:space:]]}"

if [ "$AHEAD" = "0" ] && [ "$BEHIND" = "0" ]; then
    echo ""
else
    echo "󰊢"
fi
