# shellcheck shell=bash
#
# wt — git worktree CLI helper.
#
# Subcommands:
#   wt new [--go] [--bin <name>]   create a sibling worktree (interactive)
#   wt cd                          picker → cd to a worktree
#   wt ls                          list worktrees with clean/dirty state
#   wt rm                          picker → remove worktree(s)
#   wt main                        cd to the primary worktree of current repo
#   wt prune                       git worktree prune (cleans dead refs)
#   wt help | -h | --help          show usage
#
# Lives sourced (see home/.zshrc) so `cd` affects the caller's shell.

_WT_COPY_FILES=(.env .commitcraft.toml)

_wt_help() {
    cat <<'EOF'
wt — git worktree helper

Usage:
  wt new [--go] [--bin <name>]   Create a sibling worktree (interactive).
                                 --go builds ./bin/<name> and emits ./activate.
  wt cd                          Pick a worktree and cd into it.
  wt ls                          List worktrees with branch + clean/dirty state.
  wt rm                          Pick worktree(s) to remove (multi-select).
  wt main                        cd to the primary worktree of the current repo.
  wt prune                       Run git worktree prune.
  wt help                        This message.
EOF
}

_wt_check_deps() {
    if ! command -v gum >/dev/null 2>&1; then
        echo "wt: gum is not installed (brew install gum)" >&2
        return 1
    fi
    if ! command -v git >/dev/null 2>&1; then
        gum_log_error "$(gum_red "") git not found"
        return 1
    fi
}

_wt_require_repo() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        gum_log_error "$(gum_red "") not inside a git repository"
        return 1
    }
    printf '%s\n' "$root"
}

_wt_main_repo() {
    # First "worktree" entry of `git worktree list --porcelain` is the primary.
    git worktree list --porcelain 2>/dev/null \
        | awk '/^worktree /{print substr($0,10); exit}'
}

# Emits one line per worktree: <path>\t<branch_or_detached>\t<primary|secondary>
_wt_list() {
    git worktree list --porcelain 2>/dev/null | awk '
        /^worktree /  { if (path != "") print path "\t" branch "\t" kind;
                        path=substr($0,10); branch="(detached)"; kind=(seen?"secondary":"primary"); seen=1 }
        /^branch /    { sub("refs/heads/","",$2); branch=$2 }
        /^detached$/  { branch="(detached)" }
        END           { if (path != "") print path "\t" branch "\t" kind }
    '
}

_wt_copy_extras() {
    local src="$1" dst="$2" file
    for file in "${_WT_COPY_FILES[@]}"; do
        if [[ -f "$src/$file" ]]; then
            cp "$src/$file" "$dst/$file"
            gum_log_info "$(git_strong_white_dark " ") copied $(gum_green "$file")"
        fi
    done
}

_wt_new() {
    local build_go=false bin_name=""
    while (($#)); do
        case "$1" in
            --go)  build_go=true; shift ;;
            --bin) bin_name="$2"; shift 2 ;;
            *)     gum_log_warning "$(gum_yellow_dark "󰀪") unknown flag: $1"; return 1 ;;
        esac
    done

    local repo
    repo=$(_wt_require_repo) || return 1

    local branches branch
    branches=$(git -C "$repo" for-each-ref --format='%(refname:short)' refs/heads/)
    branch=$(printf "<new branch>\n%s" "$branches" | gum choose --header "Branch")
    if [[ "$branch" == "<new branch>" ]]; then
        branch=$(gum input --header "New branch name" --placeholder "feat-x")
    fi
    if [[ -z "$branch" ]]; then
        gum_log_error "$(gum_red "") branch name is required"
        return 1
    fi

    local default_bin worktree
    default_bin=$(basename "$repo")
    [[ -z "$bin_name" ]] && bin_name="$default_bin"
    worktree="${repo}-${branch}"

    if [[ -e "$worktree" ]]; then
        gum_log_error "$(gum_red "") $worktree already exists"
        return 1
    fi

    gum style --margin "1 0" \
        "  repo:     $repo" \
        "  branch:   $branch" \
        "  worktree: $worktree" \
        "  build go: $build_go$([[ $build_go == true ]] && printf '  (bin/%s)' "$bin_name")"

    gum confirm "Create this worktree?" || { gum_log_info "aborted"; return 0; }

    if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
        gum spin --spinner dot --title "Adding existing branch as worktree..." -- \
            git -C "$repo" worktree add "$worktree" "$branch" \
            || { gum_log_error "$(gum_red "") git worktree add failed"; return 1; }
    else
        gum spin --spinner dot --title "Creating new branch + worktree..." -- \
            git -C "$repo" worktree add -b "$branch" "$worktree" \
            || { gum_log_error "$(gum_red "") git worktree add failed"; return 1; }
    fi
    gum_log_info "$(git_strong_white_dark " ") worktree $(gum_green "created") at $worktree"

    _wt_copy_extras "$repo" "$worktree"

    if [[ "$build_go" == true ]]; then
        if [[ ! -f "$worktree/go.mod" ]]; then
            gum_log_warning "$(gum_yellow_dark "󰀪") --go set but no go.mod in $worktree; skipping build"
        elif ! command -v go >/dev/null 2>&1; then
            gum_log_warning "$(gum_yellow_dark "󰀪") go not installed; skipping build"
        else
            mkdir -p "$worktree/bin"
            gum spin --spinner dot --title "Building $bin_name..." -- \
                bash -c "cd '$worktree' && go build -o './bin/$bin_name' ./..." \
                || { gum_log_warning "$(gum_red "") go build failed"; }
            if [[ -x "$worktree/bin/$bin_name" ]]; then
                cat > "$worktree/activate" <<'EOF'
# Source this file: `source ./activate`
# Prepends this worktree's ./bin so the local binary wins PATH lookup.
export PATH="$PWD/bin:$PATH"
echo "PATH updated for this worktree: $PWD/bin"
EOF
                chmod +x "$worktree/activate"
                gum_log_info "$(git_strong_white_dark " ") built $(gum_green "bin/$bin_name") + activate script"
            fi
        fi
    fi

    local next_steps="  cd \"$worktree\""
    [[ "$build_go" == true && -f "$worktree/activate" ]] && next_steps+=$'\n  source ./activate'
    gum style --border rounded --padding "1 2" --margin "1 0" --border-foreground 84 \
        "Worktree ready: $worktree" \
        "" \
        "Next steps:" \
        "$next_steps" \
        "" \
        "When done:" \
        "  wt rm   # or: git -C \"$repo\" worktree remove \"$worktree\""
}

_wt_cd() {
    _wt_check_deps || return 1
    _wt_require_repo >/dev/null || return 1

    local lines pick path
    lines=$(_wt_list) || return 1
    [[ -z "$lines" ]] && { gum_log_warning "no worktrees"; return 0; }

    pick=$(printf '%s\n' "$lines" \
        | awk -F'\t' '{ marker=($3=="primary"?"★":" "); printf "%s  %-30s %s\n", marker, $2, $1 }' \
        | gum choose --header "cd to worktree")
    [[ -z "$pick" ]] && return 0

    path=${pick#*  }            # strip "★  " or "   "
    path=${path#*[[:space:]]}   # strip branch column
    path=$(printf '%s' "$path" | sed -E 's/^[[:space:]]+//')
    cd "$path" || return 1
}

_wt_ls() {
    _wt_check_deps || return 1
    _wt_require_repo >/dev/null || return 1

    local lines path branch kind state_str marker
    lines=$(_wt_list) || return 1
    while IFS=$'\t' read -r path branch kind; do
        [[ -z "$path" ]] && continue
        if [[ -n "$(git -C "$path" status --porcelain 2>/dev/null | head -n1)" ]]; then
            state_str=$(gum_yellow_bold "dirty")
        else
            state_str=$(gum_green "clean")
        fi
        marker=" "
        [[ "$kind" == "primary" ]] && marker=$(gum_green "★")
        printf '%s  %-6s  %-25s  %s\n' \
            "$marker" "$state_str" "$(gum_yellow_bold "$branch")" "$(git_strong_white_dark "$path")"
    done <<<"$lines"
}

_wt_rm() {
    _wt_check_deps || return 1
    _wt_require_repo >/dev/null || return 1

    local lines secondary picks pick path
    lines=$(_wt_list) || return 1
    secondary=$(printf '%s\n' "$lines" | awk -F'\t' '$3=="secondary"')
    if [[ -z "$secondary" ]]; then
        gum_log_info "$(git_strong_white_dark " ") no secondary worktrees to remove"
        return 0
    fi

    picks=$(printf '%s\n' "$secondary" \
        | awk -F'\t' '{ printf "%-30s %s\n", $2, $1 }' \
        | gum choose --no-limit --header "Remove worktree(s) (space to toggle)")
    [[ -z "$picks" ]] && { gum_log_info "aborted"; return 0; }

    gum confirm "Remove the selected worktree(s)?" || { gum_log_info "aborted"; return 0; }

    while IFS= read -r pick; do
        [[ -z "$pick" ]] && continue
        path=$(printf '%s' "$pick" | awk '{$1=""; sub(/^ +/,""); print}')
        if git worktree remove "$path" 2>/dev/null; then
            gum_log_info "$(git_strong_white_dark " ") removed $(gum_green "$path")"
        else
            if gum confirm "$(gum_yellow_bold "$path") is dirty or locked. Force remove?"; then
                if git worktree remove --force "$path"; then
                    gum_log_info "$(git_strong_white_dark " ") force-removed $(gum_green "$path")"
                else
                    gum_log_error "$(gum_red "") failed to remove $path"
                fi
            else
                gum_log_info "$(git_strong_white_dark " ") skipped $path"
            fi
        fi
    done <<<"$picks"
}

_wt_main() {
    _wt_check_deps || return 1
    _wt_require_repo >/dev/null || return 1
    local main
    main=$(_wt_main_repo)
    [[ -z "$main" ]] && { gum_log_error "$(gum_red "") could not resolve primary worktree"; return 1; }
    cd "$main" || return 1
}

_wt_prune() {
    _wt_check_deps || return 1
    _wt_require_repo >/dev/null || return 1
    local out
    out=$(git worktree prune -v 2>&1)
    if [[ -z "$out" ]]; then
        gum_log_info "$(git_strong_white_dark " ") nothing to prune"
    else
        pipe_output_to_gum_log "cmd_output=$out" "function_log=gum_log_info"
    fi
}

function wt() {
    _wt_check_deps || return 1
    case "${1:-help}" in
        new|n)            shift; _wt_new "$@" ;;
        cd|c)             shift; _wt_cd "$@" ;;
        ls|l|list)        shift; _wt_ls "$@" ;;
        rm|r|remove)      shift; _wt_rm "$@" ;;
        main|m)           shift; _wt_main "$@" ;;
        prune|p)          shift; _wt_prune "$@" ;;
        help|-h|--help)   _wt_help ;;
        *)                gum_log_warning "$(gum_yellow_dark "󰀪") unknown subcommand: $1"; _wt_help; return 1 ;;
    esac
}
