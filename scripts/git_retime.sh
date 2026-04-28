# shellcheck shell=bash
#* Reescribe la fecha de un commit existente. UI con gum.

_gretime_is_gnu_date() {
    date --version >/dev/null 2>&1
}

_gretime_format_date() {
    # Convierte "YYYY-MM-DD HH:MM:SS" → RFC2822, o "now" → fecha actual.
    local input="$1"
    if [[ "$input" == "now" ]]; then
        date +"%a, %d %b %Y %H:%M:%S %z"
        return 0
    fi
    if _gretime_is_gnu_date; then
        date -d "$input" +"%a, %d %b %Y %H:%M:%S %z" 2>/dev/null
    else
        date -j -f "%Y-%m-%d %H:%M:%S" "$input" +"%a, %d %b %Y %H:%M:%S %z" 2>/dev/null
    fi
}

_gretime_is_pushed() {
    local hash="$1" upstream
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || return 1
    [[ -n "$upstream" ]] || return 1
    git branch -r --contains "$hash" 2>/dev/null | grep -q .
}

function gretime() {
    local count=20 preselected_hash=""
    if [[ -n "$1" ]]; then
        if [[ "$1" =~ ^[0-9]+$ ]] && [[ "${#1}" -le 3 ]]; then
            count="$1"
        else
            preselected_hash="$1"
        fi
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        gum_log_error "$(gum_red "") Not inside a git repository"
        return 1
    fi

    if [[ -n "$(git status --porcelain)" ]]; then
        gum_log_warning "$(gum_yellow_dark "󰀪") Working tree has uncommitted changes; commit or stash before $(gum_yellow_bold "gretime")"
        return 1
    fi

    if [[ -d "$(git rev-parse --git-dir)/rebase-merge" ]] || [[ -d "$(git rev-parse --git-dir)/rebase-apply" ]]; then
        gum_log_warning "$(gum_yellow_dark "󰀪") A rebase is already in progress; resolve it first"
        return 1
    fi

    local commit_list selected hash short subject current_date
    if [[ -n "$preselected_hash" ]]; then
        hash=$(git rev-parse --verify "$preselected_hash" 2>/dev/null) || {
            gum_log_error "$(gum_red "") Not a valid commit: $(gum_yellow_bold "$preselected_hash")"
            return 1
        }
        short=$(git rev-parse --short "$hash")
        current_date=$(git show -s --format=%ai "$hash")
        subject=$(git show -s --format=%s "$hash")
        gum_log_info "$(git_strong_white_dark " ") gretime $(git_green "Re-timing") $(gum_blue_bold "$short")"
    else
        gum_log_info "$(git_strong_white_dark " ") gretime $(git_green "Pick a commit")"
        commit_list=$(git log -n "$count" --format='%h │ %ai │ %s' 2>/dev/null)
        if [[ -z "$commit_list" ]]; then
            gum_log_error "$(gum_red "") No commits found"
            return 1
        fi

        selected=$(echo "$commit_list" | gum choose \
            --header "Select the commit to re-time (last $count)" \
            --height 20)
        if [[ -z "$selected" ]]; then
            gum_log_info "$(git_strong_white_dark " ") No selection; $(gum_yellow_bold "aborting")"
            return 0
        fi

        short=$(echo "$selected" | awk -F' │ ' '{print $1}' | tr -d ' ')
        current_date=$(echo "$selected" | awk -F' │ ' '{print $2}')
        subject=$(echo "$selected" | awk -F' │ ' '{print $3}')
        hash=$(git rev-parse "$short") || {
            gum_log_error "$(gum_red "") Could not resolve $short"
            return 1
        }
    fi

    gum_log_info "$(git_strong_white_dark " ") Target: $(gum_blue_bold "$short") $(gum_yellow_dark "($current_date)") $subject"

    local mode author_date committer_date
    author_date=$(git show -s --format=%aI "$hash")
    committer_date=$(git show -s --format=%cI "$hash")

    local mode_options="Now (set author + committer to current time)
Custom (enter a specific date)"
    if [[ "$author_date" != "$committer_date" ]]; then
        mode_options="$mode_options
Sync (set committer = author = $author_date)"
    fi

    mode=$(echo "$mode_options" | gum choose --header "How do you want to re-time this commit?")
    if [[ -z "$mode" ]]; then
        gum_log_info "$(git_strong_white_dark " ") No mode selected; $(gum_yellow_bold "aborting")"
        return 0
    fi

    local new_date
    case "$mode" in
        Now*)
            new_date=$(_gretime_format_date "now")
            ;;
        Custom*)
            local raw
            raw=$(gum input --placeholder "YYYY-MM-DD HH:MM:SS" --prompt "󰃰  ")
            if [[ -z "$raw" ]]; then
                gum_log_info "$(git_strong_white_dark " ") Empty input; $(gum_yellow_bold "aborting")"
                return 0
            fi
            new_date=$(_gretime_format_date "$raw")
            if [[ -z "$new_date" ]]; then
                gum_log_error "$(gum_red "") Invalid date: $(gum_yellow_bold "$raw") (expected YYYY-MM-DD HH:MM:SS)"
                return 1
            fi
            ;;
        Sync*)
            new_date="$author_date"
            ;;
        *)
            gum_log_error "$(gum_red "") Unknown mode"
            return 1
            ;;
    esac

    gum_log_warning "$(gum_yellow_dark "󰀪") This will $(gum_yellow_bold "rewrite history") starting at $short"
    if _gretime_is_pushed "$hash"; then
        gum_log_warning "$(gum_yellow_dark "󰀪") Commit is already on the remote; you'll need $(gum_yellow_bold "git push --force-with-lease") afterwards"
    fi
    gum_log_info "$(git_strong_white_dark " ") New date: $(gum_green "$new_date")"

    if ! gum confirm "Apply new date to $short?"; then
        gum_log_info "$(git_strong_white_dark " ") Cancelled by user"
        return 0
    fi

    local sync_only=false
    [[ "$mode" == Sync* ]] && sync_only=true

    if [[ "$hash" == "$(git rev-parse HEAD)" ]]; then
        if $sync_only; then
            GIT_COMMITTER_DATE="$new_date" git commit --amend --no-edit >/dev/null
        else
            GIT_COMMITTER_DATE="$new_date" git commit --amend --no-edit --date="$new_date" >/dev/null
        fi
        if [[ $? -ne 0 ]]; then
            gum_log_error "$(gum_red "") amend failed"
            return 1
        fi
    else
        local seq_editor
        seq_editor=$(mktemp)
        cat >"$seq_editor" <<EOF
#!/usr/bin/env bash
sed -i.bak "s/^pick ${short}/edit ${short}/" "\$1" && rm -f "\$1.bak"
EOF
        chmod +x "$seq_editor"

        local rebase_out
        rebase_out=$(GIT_SEQUENCE_EDITOR="$seq_editor" git rebase -i "${hash}^" 2>&1)
        if [[ $? -ne 0 ]]; then
            gum_log_error "$(gum_red "") rebase start failed"
            pipe_output_to_gum_log "cmd_output=$rebase_out" "function_log=gum_log_error"
            git rebase --abort >/dev/null 2>&1
            rm -f "$seq_editor"
            return 1
        fi

        local amend_out
        if $sync_only; then
            amend_out=$(GIT_COMMITTER_DATE="$new_date" git commit --amend --no-edit 2>&1)
        else
            amend_out=$(GIT_COMMITTER_DATE="$new_date" git commit --amend --no-edit --date="$new_date" 2>&1)
        fi
        if [[ $? -ne 0 ]]; then
            gum_log_error "$(gum_red "") amend failed during rebase"
            pipe_output_to_gum_log "cmd_output=$amend_out" "function_log=gum_log_error"
            git rebase --abort >/dev/null 2>&1
            rm -f "$seq_editor"
            return 1
        fi

        gum spin --spinner dot --title "$(gum_blue_bold "Continuing") rebase..." -- git rebase --continue >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            gum_log_error "$(gum_red "") rebase --continue failed; aborting"
            git rebase --abort >/dev/null 2>&1
            rm -f "$seq_editor"
            return 1
        fi
        rm -f "$seq_editor"
    fi

    gum_log_info "$(git_strong_white_dark " ") gretime $(gum_green "complete")"
    git log -n "$count" --format='%h │ %ci │ %s' | grep -F "$subject" | head -n1 | while IFS= read -r line; do
        gum_log_info "$(git_strong_white_dark " ") $line"
    done
}
