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

create_commit() {
    local commit_file="/tmp/fzf_git_commit"
    if [ -f "$commit_file" ]; then
        confirmation=$(cat "$commit_file" | fzf --layout=reverse --height=50% --min-height=20 --border --border-label-pos=2 \
            --bind "ctrl-x:abort+execute-silent:echo 130 > /tmp/fzf_git_exit_code" \
            --bind "ctrl-e:execute-silent:code $commit_file" \
            --bind "ctrl-r:reload(cat $commit_file)" \
            --bind change:clear-query \
            --preview-window='down,50%,border-top' \
            --preview="echo -n 'git commit -m \"' && cat $commit_file && echo '\"'" \
            --header="Enter (Create commit) - CTRL-E/R (Edit/Reload) - CTRL-X (Abort)" \
            --expect=enter)

        key=$(echo "$confirmation" | head -1)
        if [[ "$key" == "enter" ]]; then
            if [[ "$1" == "module" ]]; then
                git commit -F "$commit_file"
            elif [[ "$1" == "submodule" ]]; then
                local base_dir=$(pwd)
                local parent_dir=$(dirname "$base_dir")
                git -C "$parent_dir" commit -F "$commit_file"
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
        echo "List of available commands:\n- $(blue_bold 'log') or $(purple_underlie '-l') (default)\n- $(red_bold 'cherry') or $(purple_underlie '-c')\n- $(green_bold 'status') or $(purple_underlie '-s')\n- $(green_bold 'commit') or $(purple_underlie '-sc')\n- $(green_bold 'ammend') or $(purple_underlie '-am')\n- $(yellow_bold 'checkout') or $(purple_underlie '-ck')\n- $(cyan_bold '--checkout-new_branch') or $(purple_underlie '-ckb')\n- $(cyan_bold '--checkout-remote-branch') or $(purple_underlie '-ckr')\n- $(red_bold '--delete-branch') or $(purple_underlie '-D')\n- $(purple_bold 'remote') or $(purple_underlie '-v')\n- $(blue_bold 'stash')\n- $(red_bold '--push-interactive') or $(purple_underlie '-pi')\n- $(green_bold '--push-interactive-upstream') or $(purple_underlie '-piu')\n- $(yellow_bold 'push') or $(purple_underlie '-p')\n- $(cyan_bold '--push-force') or $(purple_underlie '-pf')\n- $(purple_bold 'pull') or $(purple_underlie '-pl')\n- $(blue_bold '--assume-unchanged') or $(purple_underlie '-un')\n- $(red_bold '--no-assume-unchanged') or $(purple_underlie '-na')\n- $(purple_bold 'reset') or $(yellow_underlie '-r')"
    else
        echo "For the list of available commands, run $(green_bold 'fgit help') or $(green_bold 'fgit -h')"
    fi
}