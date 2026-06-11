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

case "$MODE" in
    parent)    SYNC_ICON=''           OUT_ICON='' ;;
    dotfiles)  SYNC_ICON='' OUT_ICON='󰊢' ;;
    current|*) SYNC_ICON=''           OUT_ICON='󰊢' ;;
esac

FETCH_THROTTLE=300   # don't refetch more often than every 5 min
STALE_AFTER=600      # if last successful fetch >10 min ago, consider data stale

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-posh-repo-status"
mkdir -p "$CACHE_DIR" 2>/dev/null

mtime() {
    [ -f "$1" ] || { echo 0; return; }
    # GNU coreutils first (`stat -c %Y`): on Linux the BSD form `stat -f %m`
    # is `--file-system` mode where %m is not a valid directive — it prints
    # garbage yet exits 0, so it must not be tried first. BSD/macOS falls back
    # to `stat -f %m`. Any non-numeric result degrades to 0 (treated as "never").
    local t
    t=$(stat -c %Y "$1" 2>/dev/null) || t=$(stat -f %m "$1" 2>/dev/null)
    case "$t" in
        '' | *[!0-9]*) echo 0 ;;
        *) echo "$t" ;;
    esac
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

# When the last successful fetch is old (or never happened), stay silent rather
# than drawing 󱛅. The bg fetch we just kicked off will land before the next
# prompt and the segment will reappear naturally with fresh data.
LAST_SUCCESS=$(mtime "$SUCCESS_FILE")
if [ "$LAST_SUCCESS" = "0" ] || [ $((NOW - LAST_SUCCESS)) -gt "$STALE_AFTER" ]; then
    exit 0
fi

AHEAD="${COUNTS%%[[:space:]]*}"
BEHIND="${COUNTS##*[[:space:]]}"

if [ "$AHEAD" = "0" ] && [ "$BEHIND" = "0" ]; then
    echo "$SYNC_ICON"
else
    echo "$OUT_ICON"
fi
