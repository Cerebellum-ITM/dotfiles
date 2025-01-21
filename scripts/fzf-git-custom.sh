# shellcheck shell=bash
fzf_git_check_abort(){
    if [ -f /tmp/fzf_git_exit_code ] && [ "$(cat /tmp/fzf_git_exit_code)" -eq 130 ]; then
        gun_log_fatal "Process aborted by the $(git_strong_white "user")"
        rm /tmp/fzf_git_exit_code
        return 1
    fi
}

_check_for_git_repository(){
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        gun_log_fatal "There is no $(git_strong_red "git repository") in this $(git_strong_white "directory")."
        return 1
    fi
}

_check_for_git_repository_and_submodule(){
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        gun_log_fatal "There is no $(git_strong_red "git repository") in this $(git_strong_white "directory")."
        return 1
    fi
    cd .. || return 1
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        gun_log_fatal "There is no $(git_strong_red "git repository") in the $(gum_blue "parent") $(git_strong_white "directory")."
        cd - > /dev/null 2>&1 || return 1
        return 1
    fi
    cd - > /dev/null 2>&1 || return 1
}

_create_fzf_select(){
    local mode
    mode=""
    CURRENT_DIR_NAME=$(basename "$PWD")
    if [[ "$CURRENT_DIR_NAME" == *addons* ]]; then
        mode="select"
    fi
    fzf_select $mode
}

_create_commit_options(){
    local commit_options_file="/tmp/fzf_git_commit_options"
    if [ -f "$commit_options_file" ]; then
        rm "$commit_options_file"
        echo "D $(cat /tmp/fzf_git_commit)" > /tmp/fzf_git_commit_preview
    else
        echo "200" > "$commit_options_file"
        echo "P $(cat /tmp/fzf_git_commit)" > /tmp/fzf_git_commit_preview
    fi
}

_check_for_changelog(){
    if [ -f "../CHANGELOG.md" ]; then
        changelog_exists=true
    fi
}

_write_in_changelog(){
    local last_commit_info module_list changelog_path

    last_commit_info="$1"
    module_list="$2"
    changelog_path="../CHANGELOG.md"
    
    {
        echo "$last_commit_info"
        echo "$module_list" | while read -r module; do
            echo "  - Module: $module"
        done
    } >> "$changelog_path"
}

_check_remote_source(){
    remote_count=$(git remote | wc -l)
    if [[ "$remote_count" -gt 1 ]]; then 
        remote=$(git remote | gum choose)
    elif [[ "$remote_count" -eq 0 ]];then
        gun_log_fatal "$(git_strong_red 󱓌) - $(git_strong_red_bold "Error") There is no $(gum_cyan_bold "branch") to make the $(gum_yellow_underline "commit") in the repository."
    else 
        remote=$(git remote)
    fi
    echo "$remote"
}

# shellcheck disable=SC2120
_force_push_to_repository(){
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

    if git push -f "$remote" "$branch"
        then
            gum_log_info "$(git_strong_red 󰊢) - The $(git_strong_red "commit") was $(gum_red_underline "forced") into the repository $(git_green_light  "successfully")." "remote" "$remote" "branch" "$branch"
        else
            gun_log_fatal "$(git_strong_red 󰊢) - There was a $(git_strong_red_bold "problem") when making the $(git_strong_red "commit") in the $(gum_blue_bold_underline parent) repository."
    fi
}

# shellcheck disable=SC2120
_push_to_repository(){
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
        submodule_message="in the $(gum_blue_bold_underline parent) repository"
    fi

    cmd=("git" "push")
    cmd+=("$remote" "$branch")
    [[ -n "$flag" ]] && cmd+=("$flag")

    if "${cmd[@]}";
        then
            gum_log_info "$(git_strong_red 󰊢) - The $(git_strong_red "commit") has been uploaded $(git_green_light  "successfully")$submodule_message."
        else
            gun_log_fatal "$(git_strong_red 󰊢) - There was a $(git_strong_red_bold "problem") when making the $(git_strong_red "commit")$submodule_message."
    fi
}

create_commit() {
    local commit_file="/tmp/fzf_git_commit"
    local commit_preview_file="/tmp/fzf_git_commit_preview"
    if [ -f "$commit_file" ]; then
        confirmation=$(cat "$commit_file" | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 \
            --bind "ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code" \
            --bind "ctrl-e:execute-silent:code $commit_file" \
            --bind "tab:execute-silent:zsh -i -c '_create_commit_options'" \
            --bind "tab:+reload(cat $commit_preview_file)" \
            --bind change:clear-query \
            --preview-window='down,50%,border-top' \
            --preview="echo -n 'git commit -m \"' && cat $commit_file && echo '\"'" \
            --header="Enter (Create commit) - CTRL-E/R (Edit/Reload) - CTRL-P (Mark to push) - CTRL-X (Abort)" \
            --expect=enter)

        key=$(echo "$confirmation" | head -1)
        if [[ "$key" == "enter" ]]; then
            local base_dir parent_dir
            base_dir=$(pwd)
            parent_dir=$(dirname "$base_dir")
            if [[ "$1" == "module" ]]; then
                if [[ "$changelog_exists" == "true" ]]; then
                    gum_log_info "Creating a change record in the Docker repository  " "changelog_exists" "$changelog_exists"
                    module_list=$(git diff --cached --name-only | awk -F/ 'NF>1 {print $1}' | sort -u)
                fi
                git commit -F "$commit_file"
                gum_log_debug "$(git_strong_red "") The $(git_strong_red "commit") has been created $(git_green_light  "successfully")."
                if [[ "$changelog_exists" == "true" ]]; then
                    last_commit_info=$(git log -1 --pretty=format:"%h %ad %s" --date=short)
                    _write_in_changelog "$last_commit_info" "$module_list"
                fi
            elif [[ "$1" == "submodule" ]]; then    
                git -C "$parent_dir" add "$base_dir"
                if [[ "$changelog_exists" == "true" ]]; then
                    git -C "$parent_dir" add "CHANGELOG.md"
                fi
                git -C "$parent_dir" commit -F "$commit_file"
                gum_log_debug "$(git_strong_red "") The $(git_strong_red "commit") has been created $(git_green_light  "successfully") in the $(gum_blue_bold_underline parent) repository."
            fi
            if [[ -f /tmp/fzf_git_commit_options ]]; then
                commit_options=$(cat /tmp/fzf_git_commit_options)
                rm /tmp/fzf_git_commit_options
                rm $commit_preview_file
                if [[ "$commit_options" -eq 200 ]]; then
                    if [[ "$1" == "module" ]]; then
                        _push_to_repository
                    elif [[ "$1" == "submodule" ]]; then
                        cd "$parent_dir" || exit
                        _push_to_repository "submodule=true"
                        cd "$base_dir" || exit
                    fi
                fi
            fi
            rm "$commit_file"
        fi
    fi
}

fzf-git() {
    if [[ "$1" == "--log" || "$1" == "-l" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_hashes 
    elif [[ "$1" == "--status" || "$1" == "-s" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_files
    elif [[ "$1" == "--commit" || "$1" == "-sc" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_files
        fzf_git_check_abort || return 1
        local type_of_commit
        type_of_commit=$(awk -F': ' '{print $1 "\t" $2}' "$HOME/dotfiles/git/commits_guide_lines.txt" | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 --color=fg:yellow,hl:green,preview-fg:white --bind "ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code" --preview-window='right,90%,border-left' --delimiter="\t" --with-nth=1 --preview="echo 'Select type of commit - CTRL-X (abort)' && echo {} | cut -f2" | cut -f1)
        fzf_git_check_abort || return 1
        file_or_folder=$(_create_fzf_select)
        fzf_git_check_abort || return 1
        message=$(_fzf_translate_main_function)
        fzf_git_check_abort || return 1
        echo -n "$type_of_commit $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit module
        fzf_git_check_abort || return 1
    elif [[ "$1" == "--commit-submodule" || "$1" == "-scs" ]]; then
        local module_list changelog_exists
        _check_for_git_repository_and_submodule || return 1
        module_list=''
        changelog_exists=false
        _fzf_git_files
        fzf_git_check_abort || return 1
        local type_of_commit
        type_of_commit=$(awk -F': ' '{print $1 "\t" $2}' $HOME/dotfiles/git/commits_guide_lines.txt | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 --color=fg:yellow,hl:green,preview-fg:white --bind "ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code" --preview-window='right,90%,border-left' --delimiter="\t" --with-nth=1 --preview="echo 'Select type of commit - CTRL-X (abort)' && echo {} | cut -f2" | cut -f1)
        fzf_git_check_abort || return 1
        file_or_folder=$(_create_fzf_select)
        fzf_git_check_abort || return 1
        message=$(_fzf_translate_main_function)
        fzf_git_check_abort || return 1
        echo -n "$type_of_commit $file_or_folder: $message" > /tmp/fzf_git_commit
        _check_for_changelog
        create_commit module
        gum spin --spinner dot --title "$(git_strong_red ) Starting the $(git_strong_red commit) process in the $(gum_blue_bold_underline parent) repository" -- sleep 0.5
        fzf_git_check_abort || return 1
        submodule_commit_type=$(echo "$type_of_commit" | sed 's/[^a-zA-Z]//g')
        echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit submodule
        fzf_git_check_abort || return 1
    elif [[ "$1" == "--create-submodule-commit" || "$1" == "-csc" ]]; then
        local commit_hash
        _check_for_git_repository_and_submodule || return 1
        commit_hash=$(_fzf_git_hashes)
        commit_message=$(git log -1 --pretty=%B "$commit_hash")
        submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
        file_or_folder=$(echo "$commit_message" | awk -F'[][]' '{print $2}' | awk -F' ' '{print $2}')
        message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
        echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit submodule
        fzf_git_check_abort || return 1
    elif [[ "$1" == "--amend" || "$1" == "-am" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_files
        git commit --amend --no-edit
        _force_push_to_repository
    elif [[ "$1" == "--amend-submodule" || "$1" == "-ams" ]]; then
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
    elif [[ "$1" == "--checkout" || "$1" == "-ck" ]]; then
        _check_for_git_repository || return 1
        git checkout "$(_fzf_git_branches)"
    elif [[ "$1" == "--checkout-new_branch" || "$1" == "-ckb" ]]; then
        _check_for_git_repository || return 1
        if [[ -z "$2" ]]; then
            gun_log_fatal "$(gum_red_bold 'Error'): No $(gum_green_bold_underline "branch name") provided"
            gum_log_warning "$(gum_yellow_underline "Usage"): $(gum_blue_underline '󰘳 --checkout-new_branch') $(gum_red_bold '<branch_name>') $(gum_yellow_underline 'or') $(gum_blue_underline '󰘳 -ckb') $(gum_red_bold '<branch_name>')"
        else
            git checkout -b "$2"
            gum_log_info "$(gum_green_bold_underline "") checkout to $2 $(gum_green_bold "completed") successfully."
        fi
    elif [[ "$1" == "--checkout-remote-branch" || "$1" == "-ckr" ]]; then
        local branch branch_name
        _check_for_git_repository || return 1
        branch=$(_fzf_git_branches)
        branch_name=$(echo "$branch" | cut -d'/' -f2)
        git checkout -b "$branch_name" "$branch"
        gum_log_info "$(gum_green_bold_underline "") checkout to $branch_name $branch $(gum_green_bold "completed") successfully."
    elif [[ "$1" == "--delete-branch" || "$1" == "-D" ]]; then
        _check_for_git_repository || return 1
        git branch -D "$(_fzf_git_branches)"
    elif [[ "$1" == "cherry" || "$1" == "-c" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_hashes | while read -r hash; do
            git cherry-pick "$hash"
            gum_log_info "$(gum_green_bold_underline "") checkout to $branch_name $branch $(gum_green_bold "completed") successfully."
        done
    elif [[ "$1" == "--cherry-with-submodule" || "$1" == "-cws" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_hashes | while read -r hash; do
            git cherry-pick "$hash"
            commit_message=$(git log -1 --pretty=%B "$commit_hash")
            submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
            file_or_folder=$(echo "$commit_message" | awk -F'[][]' '{print $2}' | awk -F' ' '{print $2}')
            message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
            echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
            create_commit submodule
            fzf_git_check_abort || return 1
        done
    elif [[ "$1" == "--remote" || "$1" == "-v" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_remotes
    elif [[ "$1" == "--stash" || "$1" == "-sh" ]]; then
        _check_for_git_repository || return 1
        _fzf_git_stashes
    elif [[ "$1" == "--reset" || "$1" == "-r" ]]; then
        local commit_hash
        _check_for_git_repository || return 1
        commit_hash=$(_fzf_git_hashes)
        if [[ -n "$commit_hash" ]]; then
            git reset --hard "$commit_hash"
            gum_log_info "$(gum_red_bold_underline "") Reset to $(gum_yellow_dark_bold_underline "commit") $(gum_blue_bold_underline "  $commit_hash")"
        else
            gun_log_fatal "$(gum_red_bold_underline "") No $(gum_yellow_dark_bold_underline "commit") selected"
        fi
    elif [[ "$1" == "--push-interactive" || "$1" == "-pi" ]]; then
        local remote branch
        _check_for_git_repository || return 1
        remote=$(_fzf_git_remotes)
        branch=$(_fzf_git_branches)
        _push_to_repository "remote=$remote" "branch=$branch" 
    elif [[ "$1" == "--push-interactive-upstream" || "$1" == "-piu" ]]; then
        local remote branch
        _check_for_git_repository || return 1
        remote=$(_fzf_git_remotes)
        branch=$(_fzf_git_branches)
        _push_to_repository "remote=$remote" "branch=$branch" "flag=-u"
    elif [[ "$1" == "--push" || "$1" == "-p" ]]; then
        _check_for_git_repository || return 1
        _push_to_repository  
    elif [[ "$1" == "--push-force" || "$1" == "-pf" ]]; then
        _check_for_git_repository || return 1
        _force_push_to_repository
    elif [[ "$1" == "--pull" || "$1" == "-pl" ]]; then
        _check_for_git_repository || return 1
        git pull
        gum_log_info "$(git_strong_red 󰊢) - The repository was updated $(git_green_light "successfully")."
    elif [[ "$1" == "--assume-unchanged" || "$1" == "-un" ]]; then
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
    elif [[ "$1" == "--no-assume-unchanged" || "$1" == "-na" ]]; then
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
    elif [[ "$1" == "--diff" || "$1" == "-df" ]]; then
        _check_for_git_repository || return 1
        hashes=$(_fzf_git_hashes)
        hash1=$(echo "$hashes" | sed -n '1p')
        hash2=$(echo "$hashes" | sed -n '2p')
        git diff "$hash1" "$hash2"
    elif [[ "$1" == "--help" || "$1" == "-h" ]]; then
        gum format -t markdown --theme="tokyo-night" < "$HOME/dotfiles/docs/function_fzf-git_help.md" | gum pager --soft-wrap=false
    else
        local cmd_options branch_name
        branch_name=""

        gum format -t markdown --theme="tokyo-night" < "$HOME/dotfiles/docs/function_fzf-git_help.md" | gum pager --soft-wrap=false
        gum confirm "Search the commands" && CONTINUE=true || CONTINUE=false
        if [[ $CONTINUE == "true" ]]; then
            cmd_options=$(echo -e "--log\n--cherry\n--cherry-with-submodule\n--status\n--commit\n--commit-submodule\n--create-submodule-commit\n--amend\n--amend-submodule\n--checkout\n--checkout-new_branch\n--checkout-remote-branch\n--delete-branch\n--remote\n--stash\n--reset\n--push-interactive\n--push-interactive-upstream\n--push\n--push-force\n--pull\n--assume-unchanged\n--no-assume-unchanged\n--diff" | gum filter)
            if [[ $cmd_options == '--checkout-new_branch' ]]; then
                branch_name=$(gum input --cursor.foreground "#FF0" \
                --prompt.foreground "#0FF" \
                --prompt "* Name of the new branch: " \
                --placeholder "new_feature" \
                --width 80
                )
            fi
            fzf-git "$cmd_options" "$branch_name"
            gum_log_debug "The following command will be executed: $(gum_green_dark "fzf-git") $(gum_blue_dark "󰘳 $cmd_options") $(gum_cyan_dark_bold "$branch_name")"
        fi
    fi
}