fzf_select() {
    trap 'rm -f /tmp/initial_path' EXIT

    local multi_select=""
    local mode="${1:-select}"
    if [[ "$1" == "-m" ]]; then
        multi_select="-m"
        mode="select"
        echo $multi_select > /tmp/fzf_select_multi
    fi

    if [[ -f /tmp/fzf_select_multi ]]; then
        multi_select=$(cat /tmp/fzf_select_multi)
        rm /tmp/fzf_select_multi
    fi
    
    if [[ ! -f /tmp/initial_path ]]; then
        echo $PWD > /tmp/initial_path
    fi
    
    
    while true; do
        if [[ "$mode" == "select" ]]; then
            header="Modo: SELECT (ctrl-w para cambiar a PATH CHANGER) - CTRL-X (abort)"
            color="header:bright-green"
        else
            header="Modo: PATH CHANGER (ctrl-s para cambiar a SELECT) - CTRL-X (abort)"
            color="header:bright-magenta"
        fi

        selected=$(find . -maxdepth 1 -mindepth 1 -type d -o -type f 2> /dev/null | \
            awk 'BEGIN {print ".."} {print}' | \
            FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border \
                --preview='[[ -d {} ]] && tree -L 1 {} || bat -n --color=always {}' \
                --header='$header' \
                --color='$color' \
                --bind 'ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code' \
                --bind 'ctrl-w:execute-silent(echo path_changer > /tmp/fzf_mode && echo $multi_select > /tmp/fzf_select_multi)+abort' \
                --bind 'ctrl-s:execute-silent(echo select > /tmp/fzf_mode && echo $multi_select > /tmp/fzf_select_multi)+abort'" \
            fzf $multi_select)

        if [[ -z "$selected" ]]; then
            break
        fi

        if [[ "$selected" == ".." ]]; then
            cd ..
            fzf_select "$mode" $multi_select
        elif [[ "$mode" == "path_changer" && -d "$selected" ]]; then
            cd "$selected"
            fzf_select "select" $multi_select
        else
            if [[ -n "$multi_select" ]]; then
                echo $selected
            else
                echo "$(basename "$selected")"
            fi
            initial_path=$(cat /tmp/initial_path)
            cd $initial_path
            rm /tmp/initial_path
        fi
        break
    done

    if [[ -f /tmp/fzf_mode ]]; then
        mode=$(cat /tmp/fzf_mode)
        rm /tmp/fzf_mode
        fzf_select "$mode" $multi_select
    fi
}
fzf_git_check_abort(){
    if [ -f /tmp/fzf_git_exit_code ] && [ "$(cat /tmp/fzf_git_exit_code)" -eq 130 ]; then
        echo $(red_bold "Process aborted")
        rm /tmp/fzf_git_exit_code
        return 1
    fi
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
            local base_dir=$(pwd)
            local parent_dir=$(dirname "$base_dir")
            if [[ "$1" == "module" ]]; then
                git commit -F "$commit_file"
            elif [[ "$1" == "submodule" ]]; then    
                git -C "$parent_dir" add "$base_dir"
                git -C "$parent_dir" commit -F "$commit_file"
            fi
            if [[ -f /tmp/fzf_git_commit_options ]]; then
                commit_options=$(cat /tmp/fzf_git_commit_options)
                rm /tmp/fzf_git_commit_options
                rm $commit_preview_file
                if [[ "$commit_options" -eq 200 ]]; then
                    if [[ "$1" == "module" ]]; then
                        local branch=$(git branch --show-current)
                        local remote=$(git remote)
                        git push $remote $branch
                    elif [[ "$1" == "submodule" ]]; then
                        cd "$parent_dir"
                        local branch=$(git branch --show-current)
                        local remote=$(git remote)
                        git push $remote $branch
                        cd "$base_dir"
                    fi
                fi
            fi
            rm "$commit_file"
        fi
    fi
}

fzf-git() {
    if [[ "$1" == "log" || "$1" == "-l" ]]; then
        _fzf_git_hashes 
    elif [[ "$1" == "status" || "$1" == "-s" ]]; then
        _fzf_git_files
    elif [[ "$1" == "commit" || "$1" == "-sc" ]]; then
        _fzf_git_files
        fzf_git_check_abort || return 1
        local type_of_commit
        type_of_commit=$(awk -F': ' '{print $1 "\t" $2}' $HOME/dotfiles/git/commits_guide_lines.txt | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 --color=fg:yellow,hl:green,preview-fg:white --bind "ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code" --preview-window='right,90%,border-left' --delimiter="\t" --with-nth=1 --preview="echo 'Select type of commit - CTRL-X (abort)' && echo {} | cut -f2" | cut -f1)
        fzf_git_check_abort || return 1
        file_or_folder=$(fzf_select)
        fzf_git_check_abort || return 1
        message=$(_fzf_translate_main_function)
        fzf_git_check_abort || return 1
        echo -n "$type_of_commit $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit module
        fzf_git_check_abort || return 1
    elif [[ "$1" == "commit-submodule" || "$1" == "-scs" ]]; then
        _fzf_git_files
        fzf_git_check_abort || return 1
        local type_of_commit
        type_of_commit=$(awk -F': ' '{print $1 "\t" $2}' $HOME/dotfiles/git/commits_guide_lines.txt | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 --color=fg:yellow,hl:green,preview-fg:white --bind "ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code" --preview-window='right,90%,border-left' --delimiter="\t" --with-nth=1 --preview="echo 'Select type of commit - CTRL-X (abort)' && echo {} | cut -f2" | cut -f1)
        fzf_git_check_abort || return 1
        file_or_folder=$(fzf_select)
        fzf_git_check_abort || return 1
        message=$(_fzf_translate_main_function)
        fzf_git_check_abort || return 1
        echo -n "$type_of_commit $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit module
        fzf_git_check_abort || return 1
        submodule_commit_type=$(echo "$type_of_commit" | sed 's/[^a-zA-Z]//g')
        echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit submodule
        fzf_git_check_abort || return 1
    elif [[ "$1" == "create-submodule-commit" || "$1" == "-csc" ]]; then
        local commit_hash=$(_fzf_git_hashes)
        commit_message=$(git log -1 --pretty=%B $commit_hash)
        submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
        file_or_folder=$(echo "$commit_message" | awk -F'[][]' '{print $2}' | awk -F' ' '{print $2}')
        message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
        echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
        create_commit submodule
        fzf_git_check_abort || return 1
    elif [[ "$1" == "amend" || "$1" == "-am" ]]; then
        _fzf_git_files
        git commit --amend --no-edit
        git push -f
    elif [[ "$1" == "checkout" || "$1" == "-ck" ]]; then
        git checkout $(_fzf_git_branches)
    elif [[ "$1" == "--checkout-new_branch" || "$1" == "-ckb" ]]; then
        if [[ -z "$2" ]]; then
            echo "$(red_bold 'Error: No branch name provided.')"
            echo "Usage: $(green_bold 'checkout new_branch') $(purple_underlie '<branch_name>') $(green_bold 'or') $(green_bold '-ckb') $(purple_underlie '<branch_name>')"
        else
            git checkout -b $2
        fi
    elif [[ "$1" == "--checkout-remote-branch" || "$1" == "-ckr" ]]; then
        local branch=$(_fzf_git_branches)
        branch_name=$(echo "$branch" | cut -d'/' -f2)
        git checkout -b $branch_name $branch
    elif [[ "$1" == "--delete-branch" || "$1" == "-D" ]]; then
        git branch -D $(_fzf_git_branches)
    elif [[ "$1" == "cherry" || "$1" == "-c" ]]; then
        _fzf_git_hashes | while read -r hash; do
            git cherry-pick "$hash"
        done
    elif [[ "$1" == "cherry-with-submodule" || "$1" == "-cws" ]]; then
        _fzf_git_hashes | while read -r hash; do
            git cherry-pick "$hash"
            commit_message=$(git log -1 --pretty=%B $commit_hash)
            submodule_commit_type=$(echo "$commit_message" | awk -F'[] []' '{print $2}')
            file_or_folder=$(echo "$commit_message" | awk -F'[][]' '{print $2}' | awk -F' ' '{print $2}')
            message=$(echo "$commit_message" | sed -n 's/^\[.*\] .*: \(.*\)/\1/p')
            echo -n "[CHECKOUT-$submodule_commit_type] $file_or_folder: $message" > /tmp/fzf_git_commit
            create_commit submodule
            fzf_git_check_abort || return 1
        done
    elif [[ "$1" == "remote" || "$1" == "-v" ]]; then
        _fzf_git_remotes
    elif [[ "$1" == "stash" ]]; then
        _fzf_git_stashes
    elif [[ "$1" == "reset" || "$1" == "-r" ]]; then
        local commit_hash=$(_fzf_git_hashes)
        if [[ -n "$commit_hash" ]]; then
            git reset --hard "$commit_hash"
            echo "Reset to commit $(blue_bold "$commit_hash")"
        else
            echo "No commit selected"
        fi
    elif [[ "$1" == "--push-interactive" || "$1" == "-pi" ]]; then
        remote=$(_fzf_git_remotes)
        branch=$(_fzf_git_branches)
        git push $remote $branch 
    elif [[ "$1" == "--push-interactive-upstream" || "$1" == "-piu" ]]; then
        remote=$(_fzf_git_remotes)
        branch=$(_fzf_git_branches)
        git push -u $remote $branch 
    elif [[ "$1" == "push" || "$1" == "-p" ]]; then
        git push  
    elif [[ "$1" == "--push-force" || "$1" == "-pf" ]]; then
        git push -f
    elif [[ "$1" == "pull" || "$1" == "-pl" ]]; then
        git pull
    elif [[ "$1" == "--assume-unchanged" || "$1" == "-un" ]]; then
        local file_or_files=$(fzf_select -m)
        original_ifs=$IFS
        IFS=$'\n'
        echo "$file_or_files" | while read -r file; do
            git update-index --assume-unchanged "$file"
        done
        IFS=$original_ifs
    elif [[ "$1" == "--no-assume-unchanged" || "$1" == "-na" ]]; then
        local file_or_files=$(fzf_select -m)
        original_ifs=$IFS
        IFS=$'\n'
        echo "$file_or_files" | while read -r file; do
            git update-index --no-assume-unchanged $file
        done
        IFS=$original_ifs
    elif [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "List of available commands:\n* $(blue_bold 'log') or $(purple_underlie '-l') (default) # Show commit logs\n* $(red_bold 'cherry') or $(purple_underlie '-c') # Cherry-pick commits\n* $(red_bold 'cherry-with-submodule') or $(purple_underlie '-cws') # Cherry-pick commits with submodule updates\n* $(yellow_bold 'status') or $(purple_underlie '-s') # Show the working tree status\n* $(green_bold 'commit') or $(purple_underlie '-sc') # Create a new commit\n* $(green_bold 'commit-submodule') or $(purple_underlie '-scs') # Create a new commit and update submodule\n* $(green_bold 'create-submodule-commit') or $(purple_underlie '-csc') # Create a commit in the submodule\n* $(yellow_bold 'amend') or $(purple_underlie '-am') # Amend the previous commit\n* $(cyan_bold 'checkout') or $(purple_underlie '-ck') # Switch branches or restore working tree files\n* $(cyan_bold '--checkout-new_branch') or $(purple_underlie '-ckb') $(purple_underlie '<branch_name>') # Create and switch to a new branch\n* $(cyan_bold '--checkout-remote-branch') or $(purple_underlie '-ckr') # Checkout a remote branch\n* $(red_bold '--delete-branch') or $(purple_underlie '-D') # Delete a branch\n* $(purple_bold 'remote') or $(purple_underlie '-v') # Manage set of tracked repositories\n* $(yellow_bold 'stash') # Stash the changes in a dirty working directory away\n* $(red_bold 'reset') or $(purple_underlie '-r') # Reset current HEAD to the specified state\n* $(blue_bold '--push-interactive') or $(purple_underlie '-pi') # Push changes interactively\n* $(blue_bold '--push-interactive-upstream') or $(purple_underlie '-piu') # Push changes interactively to upstream\n* $(blue_bold 'push') or $(purple_underlie '-p') # Push changes to the remote repository\n* $(red_bold '--push-force') or $(purple_underlie '-pf') # Force push changes to the remote repository\n* $(blue_bold 'pull') or $(purple_underlie '-pl') # Fetch from and integrate with another repository or a local branch\n* $(yellow_bold '--assume-unchanged') or $(purple_underlie '-un') # Mark files as assume unchanged\n* $(yellow_bold '--no-assume-unchanged') or $(purple_underlie '-na') # Uncheck files as assume unchanged"
    else
        echo "For the list of available commands, run $(green_bold 'fgit help') or $(green_bold 'fgit -h')"
    fi
}