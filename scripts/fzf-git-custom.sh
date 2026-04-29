# shellcheck shell=bash

readonly FZF_GIT_COMMIT_FILE="/tmp/fzf_git_commit"
readonly FZF_GIT_COMMIT_PREVIEW_FILE="/tmp/fzf_git_commit_preview"
readonly FZF_GIT_COMMIT_OPTIONS_FILE="/tmp/fzf_git_commit_options"
readonly FZF_GIT_EXIT_CODE_FILE="/tmp/fzf_git_exit_code"

fzf_git_check_abort() {
    if [ -f "$FZF_GIT_EXIT_CODE_FILE" ] && [ "$(cat "$FZF_GIT_EXIT_CODE_FILE")" -eq 130 ]; then
        gum_log_fatal "Process aborted by the $(git_strong_white "user")"
        rm "$FZF_GIT_EXIT_CODE_FILE"
        return 1
    fi
}

_check_for_git_repository() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        gum_log_fatal "There is no $(git_strong_red "git repository") in this $(git_strong_white "directory")."
        return 1
    fi
}

_check_for_git_repository_and_submodule() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        gum_log_fatal "There is no $(git_strong_red "git repository") in this $(git_strong_white "directory")."
        return 1
    fi
    cd .. || return 1
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        gum_log_fatal "There is no $(git_strong_red "git repository") in the $(gum_blue "parent") $(git_strong_white "directory")."
        cd - >/dev/null 2>&1 || return 1
        return 1
    fi
    cd - >/dev/null 2>&1 || return 1
}

_create_fzf_select() {
    local mode
    mode=""
    CURRENT_DIR_NAME=$(basename "$PWD")
    if [[ "$CURRENT_DIR_NAME" == *addons* ]]; then
        mode="select"
    fi
    fzf_select $mode
}

_fzf_commit_type_selector() {
    awk -F': ' '{print $1 "\t" $2}' "$HOME/dotfiles/git/commits_guide_lines.txt" |
        fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 \
            --color=fg:yellow,hl:green,preview-fg:white \
            --bind "ctrl-x:execute-silent(echo 130 > $FZF_GIT_EXIT_CODE_FILE)+abort" \
            --preview-window='right,90%,border-left' --delimiter="\t" --with-nth=1 \
            --preview="echo 'Select type of commit - 󰘴-X (abort)' && echo {} | cut -f2" | cut -f1
}

_create_commit_options() {
    if [ -f "$FZF_GIT_COMMIT_OPTIONS_FILE" ]; then
        rm "$FZF_GIT_COMMIT_OPTIONS_FILE"
        echo "D $(cat "$FZF_GIT_COMMIT_FILE")" >"$FZF_GIT_COMMIT_PREVIEW_FILE"
    else
        echo "200" >"$FZF_GIT_COMMIT_OPTIONS_FILE"
        echo "P $(cat "$FZF_GIT_COMMIT_FILE")" >"$FZF_GIT_COMMIT_PREVIEW_FILE"
    fi
}

# TODO: design a dedicated changelog flow. For now these are no-ops that
# announce they are skipping so callers do not silently lose behavior.
_check_for_changelog() {
    gum_log_debug "$(git_strong_red "") changelog flow $(gum_yellow_underline "skipped") (WIP)."
}

_write_in_changelog() {
    gum_log_debug "$(git_strong_red "") changelog write $(gum_yellow_underline "skipped") (WIP)."
}

_check_remote_source() {
    remote_count=$(git remote | wc -l)
    if [[ "$remote_count" -gt 1 ]]; then
        remote=$(git remote | gum choose)
    elif [[ "$remote_count" -eq 0 ]]; then
        gum_log_fatal "$(git_strong_red 󱓌) - $(git_strong_red_bold "Error") There is no $(gum_cyan_bold "branch") to make the $(gum_yellow_underline "commit") in the repository."
    else
        remote=$(git remote)
    fi
    echo "$remote"
}

# shellcheck disable=SC2120
_force_push_to_repository() {
    declare -A args
    local branch remote submodule

    for arg in "$@"; do
        key="${arg%%=*}"
        value="${arg#*=}"
        args["$key"]="$value"
    done

    branch="${args["branch"]:-$(git branch --show-current)}"
    remote="${args["remote"]:-$(_check_remote_source)}"
    submodule="${args["submodule"]:-"false"}"

    if [[ "$submodule" == 'true' ]]; then
        submodule_message=$(gum_blue_bold_underline " in the $(gum_blue_bold_underline parent) repository")
    fi

    if git push -f "$remote" "$branch"; then
        gum_log_info "$(git_strong_red 󰊢) - The $(git_strong_red "commit") was $(gum_red_underline "forced") into the repository $(git_green_light "successfully")." "remote" "$remote" "branch" "$branch"
    else
        gum_log_fatal "$(git_strong_red 󰊢) - There was a $(git_strong_red_bold "problem") when making the $(git_strong_red "commit") in the $(gum_blue_bold_underline parent) repository."
    fi
}

# shellcheck disable=SC2120
_push_to_repository() {
    declare -A args
    local cmd branch remote submodule flag

    for arg in "$@"; do
        key="${arg%%=*}"
        value="${arg#*=}"
        args["$key"]="$value"
    done

    branch="${args["branch"]:-$(git branch --show-current)}"
    remote="${args["remote"]:-$(_check_remote_source)}"
    submodule="${args["submodule"]:-"false"}"
    flag="${args["flag"]:-""}"

    if [[ "$submodule" == 'true' ]]; then
        submodule_message=" in the $(gum_blue_bold_underline parent) repository"
    fi

    cmd=("git" "push")
    cmd+=("$remote" "$branch")
    [[ -n "$flag" ]] && cmd+=("$flag")

    if "${cmd[@]}"; then
        gum_log_info "$(git_strong_red 󰊢) - The $(git_strong_red "commit") has been uploaded $(git_green_light "successfully")$submodule_message."
    else
        gum_log_fatal "$(git_strong_red 󰊢) - There was a $(git_strong_red_bold "problem") when making the $(git_strong_red "commit")$submodule_message."
    fi
}

# Commit using the message stored in $FZF_GIT_COMMIT_FILE.
# target=current commits in the cwd repo; target=parent stages cwd as a
# submodule pointer in the parent repo and commits there.
_do_commit() {
    local target="$1"
    local base_dir parent_dir

    if [[ -z "$target" ]]; then
        gum_log_fatal "$(git_strong_red "") _do_commit requires a target ($(gum_yellow_underline current) | $(gum_yellow_underline parent))."
        return 1
    fi
    if [ ! -f "$FZF_GIT_COMMIT_FILE" ]; then
        gum_log_fatal "$(git_strong_red "") No commit message file at $(gum_yellow_underline "$FZF_GIT_COMMIT_FILE")."
        return 1
    fi

    base_dir=$(pwd)
    parent_dir=$(dirname "$base_dir")

    case "$target" in
        current)
            git commit -F "$FZF_GIT_COMMIT_FILE" || return 1
            gum_log_debug "$(git_strong_red "") The $(git_strong_red "commit") has been created $(git_green_light "successfully")."
            ;;
        parent)
            git -C "$parent_dir" add "$base_dir" || return 1
            git -C "$parent_dir" commit -F "$FZF_GIT_COMMIT_FILE" || return 1
            gum_log_debug "$(git_strong_red "") The $(git_strong_red "commit") has been created $(git_green_light "successfully") in the $(gum_blue_bold_underline parent) repository."
            ;;
        *)
            gum_log_fatal "$(git_strong_red "") Unknown commit target: $(gum_yellow_underline "$target")."
            return 1
            ;;
    esac
}

# Consume the push toggle file ($FZF_GIT_COMMIT_OPTIONS_FILE = 200 means push).
# Mirrors legacy create_commit semantics: the toggle is consumed on the first
# call, so a follow-up call (e.g. parent after current) becomes a no-op.
_maybe_push() {
    local target="$1"
    local opts base_dir parent_dir

    [ -f "$FZF_GIT_COMMIT_OPTIONS_FILE" ] || return 0
    opts=$(cat "$FZF_GIT_COMMIT_OPTIONS_FILE")
    rm -f "$FZF_GIT_COMMIT_OPTIONS_FILE" "$FZF_GIT_COMMIT_PREVIEW_FILE"
    [[ "$opts" -eq 200 ]] || return 0

    case "$target" in
        current)
            _push_to_repository
            ;;
        parent)
            base_dir=$(pwd)
            parent_dir=$(dirname "$base_dir")
            cd "$parent_dir" || return 1
            _push_to_repository "submodule=true"
            cd "$base_dir" || return 1
            ;;
    esac
}

# Backwards-compat shim. Prefer _do_commit + _maybe_push directly.
create_commit() {
    local target
    case "$1" in
        module) target="current" ;;
        submodule) target="parent" ;;
        *)
            gum_log_fatal "$(git_strong_red "") create_commit: unknown arg $(gum_yellow_underline "$1")."
            return 1
            ;;
    esac
    _do_commit "$target" || return 1
    _maybe_push "$target"
}

# Collect type / target / message for a commit via fzf and write the message
# into $FZF_GIT_COMMIT_FILE. Sets caller-visible vars: type_of_commit,
# file_or_folder, message.
_collect_commit_inputs() {
    _fzf_git_files
    fzf_git_check_abort || return 1
    type_of_commit=$(_fzf_commit_type_selector)
    fzf_git_check_abort || return 1
    file_or_folder=$(_create_fzf_select)
    fzf_git_check_abort || return 1
    message=$(_fzf_translate_main_function)
    fzf_git_check_abort || return 1
}

_run_commit_flow() {
    local submodule="${1:-false}"
    local type_of_commit file_or_folder message submodule_commit_type

    _collect_commit_inputs || return 1
    echo -n "$type_of_commit $file_or_folder: $message" >"$FZF_GIT_COMMIT_FILE"
    _check_for_changelog
    _do_commit current || return 1
    _maybe_push current

    if [[ "$submodule" == "true" ]]; then
        gum spin --spinner dot --title "$(git_strong_red ) Starting the $(git_strong_red commit) process in the $(gum_blue_bold_underline parent) repository" -- sleep 0.5
        fzf_git_check_abort || return 1
        submodule_commit_type="${type_of_commit//[^a-zA-Z0-9]/}"
        echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" >"$FZF_GIT_COMMIT_FILE"
        _do_commit parent || return 1
        _maybe_push parent
    fi
}

_fzf_git_show_help() {
    gum format -t markdown --theme="tokyo-night" <"$HOME/dotfiles/docs/function_fzf-git_help.md" | gum pager --soft-wrap=false
}

fzf-git() {
    case "$1" in
        --log | -l)
            _check_for_git_repository || return 1
            _fzf_git_hashes
            ;;
        --status | -s)
            lazygit
            ;;
        --commit | -sc)
            _check_for_git_repository || return 1
            _run_commit_flow false
            ;;
        --commit-submodule | -scs)
            _check_for_git_repository_and_submodule || return 1
            _run_commit_flow true
            ;;
        --create-submodule-commit | -csc)
            local commit_hash commit_message submodule_commit_type file_or_folder message
            _check_for_git_repository_and_submodule || return 1
            commit_hash=$(_fzf_git_hashes)
            commit_message=$(git log -1 --pretty=%B "$commit_hash")
            submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
            file_or_folder=$(echo "$commit_message" | sed -E 's/.*\] ([^:]+):.*/\1/')
            message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
            echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" >"$FZF_GIT_COMMIT_FILE"
            _do_commit parent || return 1
            _maybe_push parent
            fzf_git_check_abort || return 1
            ;;
        --amend | -am)
            _check_for_git_repository || return 1
            _fzf_git_files
            git commit --amend --no-edit
            _force_push_to_repository
            ;;
        --amend-submodule | -ams)
            local base_dir parent_dir branch remote
            _check_for_git_repository || return 1
            base_dir=$(pwd)
            parent_dir=$(dirname "$base_dir")
            _fzf_git_files
            git commit --amend --no-edit
            _force_push_to_repository "submodule=true"
            cd "$parent_dir" || exit
            branch=$(git branch --show-current)
            remote=$(git remote)
            git add "$base_dir"
            git commit --amend --no-edit
            _force_push_to_repository "remote=$remote" "branch=$branch" "submodule=true"
            cd "$base_dir" || exit
            ;;
        --checkout | -ck)
            _check_for_git_repository || return 1
            git checkout "$(_fzf_git_branches)"
            ;;
        --checkout-new_branch | -ckb)
            _check_for_git_repository || return 1
            if [[ -z "$2" ]]; then
                gum_log_fatal "$(gum_red_bold 'Error'): No $(gum_green_bold_underline "branch name") provided"
                gum_log_warning "$(gum_yellow_underline "Usage"): $(gum_blue_underline '󰘳 --checkout-new_branch') $(gum_red_bold '<branch_name>') $(gum_yellow_underline 'or') $(gum_blue_underline '󰘳 -ckb') $(gum_red_bold '<branch_name>')"
            else
                git checkout -b "$2"
                gum_log_info "$(gum_green_bold_underline "") checkout to $2 $(gum_green_bold "completed") successfully."
            fi
            ;;
        --checkout-remote-branch | -ckr)
            local branch branch_name
            _check_for_git_repository || return 1
            branch=$(_fzf_git_branches)
            branch_name=$(echo "$branch" | cut -d'/' -f2)
            git checkout -b "$branch_name" "$branch"
            gum_log_info "$(gum_green_bold_underline "") checkout to $branch_name $branch $(gum_green_bold "completed") successfully."
            ;;
        --delete-branch | -D)
            _check_for_git_repository || return 1
            git branch -D "$(_fzf_git_branches)"
            ;;
        cherry | -c)
            _check_for_git_repository || return 1
            _fzf_git_hashes | while read -r hash; do
                git cherry-pick "$hash"
                gum_log_info "$(gum_green_bold_underline "") cherry-pick $hash $(gum_green_bold "completed") successfully."
            done
            ;;
        --cherry-with-submodule | -cws)
            _check_for_git_repository || return 1
            _fzf_git_hashes | while read -r hash; do
                local commit_message submodule_commit_type file_or_folder message
                git cherry-pick "$hash"
                commit_message=$(git log -1 --pretty=%B "$hash")
                submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
                file_or_folder=$(echo "$commit_message" | awk -F'[][]' '{print $2}' | awk -F' ' '{print $2}')
                message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
                echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" >"$FZF_GIT_COMMIT_FILE"
                _do_commit parent || return 1
                _maybe_push parent
                fzf_git_check_abort || return 1
            done
            ;;
        --remote | -v)
            _check_for_git_repository || return 1
            _fzf_git_remotes
            ;;
        --stash | -sh)
            _check_for_git_repository || return 1
            _fzf_git_stashes
            ;;
        --reset | -r)
            local commit_hash
            _check_for_git_repository || return 1
            commit_hash=$(_fzf_git_hashes)
            if [[ -n "$commit_hash" ]]; then
                git reset --hard "$commit_hash"
                gum_log_info "$(gum_red_bold_underline "") Reset to $(gum_yellow_dark_bold_underline "commit") $(gum_blue_bold_underline "  $commit_hash")"
            else
                gum_log_fatal "$(gum_red_bold_underline "") No $(gum_yellow_dark_bold_underline "commit") selected"
            fi
            ;;
        --push-interactive | -pi)
            local remote branch
            _check_for_git_repository || return 1
            remote=$(_fzf_git_remotes)
            branch=$(_fzf_git_branches)
            _push_to_repository "remote=$remote" "branch=$branch"
            ;;
        --push-interactive-upstream | -piu)
            local remote branch
            _check_for_git_repository || return 1
            remote=$(_fzf_git_remotes)
            branch=$(_fzf_git_branches)
            _push_to_repository "remote=$remote" "branch=$branch" "flag=-u"
            ;;
        --push | -p)
            _check_for_git_repository || return 1
            _push_to_repository
            ;;
        --push-force | -pf)
            _check_for_git_repository || return 1
            _force_push_to_repository
            ;;
        --pull | -pl)
            _check_for_git_repository || return 1
            git pull
            gum_log_info "$(git_strong_red 󰊢) - The repository was updated $(git_green_light "successfully")."
            ;;
        --assume-unchanged | -un)
            local file_or_files
            _check_for_git_repository || return 1
            file_or_files=$(fzf_select -m)
            original_ifs=$IFS
            IFS=$'\n'
            echo "$file_or_files" | while read -r file; do
                git update-index --assume-unchanged "$file"
                gum_log_warning "$(git_strong_red 󰊢) - The file $(gum_yellow_bold_underline "$file") was marked as: assume that it has no $(git_red_orange "changes")."
            done
            IFS=$original_ifs
            ;;
        --no-assume-unchanged | -na)
            local file_or_files
            _check_for_git_repository || return 1
            file_or_files=$(fzf_select -m)
            original_ifs=$IFS
            IFS=$'\n'
            echo "$file_or_files" | while read -r file; do
                git update-index --no-assume-unchanged "$file"
                gum_log_info "$(git_strong_red 󰊢) - The tracking has been $(gum_green_bold_underline "restored") to the file: $(gum_yellow_bold_underline "$file")."
            done
            IFS=$original_ifs
            ;;
        --diff | -df)
            _check_for_git_repository || return 1
            hashes=$(_fzf_git_hashes)
            hash1=$(echo "$hashes" | sed -n '1p')
            hash2=$(echo "$hashes" | sed -n '2p')
            git diff "$hash1" "$hash2"
            ;;
        --help | -h)
            _fzf_git_show_help
            ;;
        *)
            local cmd_options branch_name
            branch_name=""

            _fzf_git_show_help
            gum confirm "Search the commands" && CONTINUE=true || CONTINUE=false
            if [[ $CONTINUE == "true" ]]; then
                cmd_options=$(echo -e "--log\n--cherry\n--cherry-with-submodule\n--status\n--commit\n--commit-submodule\n--create-submodule-commit\n--amend\n--amend-submodule\n--checkout\n--checkout-new_branch\n--checkout-remote-branch\n--delete-branch\n--remote\n--stash\n--reset\n--push-interactive\n--push-interactive-upstream\n--push\n--push-force\n--pull\n--assume-unchanged\n--no-assume-unchanged\n--diff" | gum filter)
                if [[ $cmd_options == '--checkout-new_branch' ]]; then
                    branch_name=$(
                        gum input --cursor.foreground "#FF0" \
                            --prompt.foreground "#0FF" \
                            --prompt "* Name of the new branch: " \
                            --placeholder "new_feature" \
                            --width 80
                    )
                fi
                fzf-git "$cmd_options" "$branch_name"
                gum_log_debug "The following command will be executed: $(gum_green_dark "fzf-git") $(gum_blue_dark "󰘳 $cmd_options") $(gum_cyan_dark_bold "$branch_name")"
            fi
            ;;
    esac
}
