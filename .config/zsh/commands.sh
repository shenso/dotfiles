#/usr/bin/env zsh

get_branch_ahead_behind () {
    local git_params=()
    local args=()
    local arg_count=0

    for arg in "$@"; do
        if [[ "$arg" == --* ]]; then
            git_params+=("$arg")
        else
            args+=("$arg")
            ((arg_count++))
        fi
    done

    if [[ $arg_count -eq 0 ]]; then
        local cur_remote=$(command git $git_params remote show 2> /dev/null)
        local cur_branch=$(command git $git_params symbolic-ref --short HEAD 2>/dev/null)
        local other_branch=$(command git $git_params remote show $cur_remote | sed -n '/HEAD branch/s/.*: //p')
    elif [[ $arg_count -eq 1 ]]; then
        local cur_branch=$(command git $git_params symbolic-ref --short HEAD 2>/dev/null)
        local other_branch=${args[0]}
    else
        local cur_branch=${args[0]}
        local other_branch=${args[1]}
    fi

    if [[ "$cur_branch" == "" || "$other_branch" == "" ]]; then
        echo "Current and other branch could not be found!" >> /dev/stderr
        return 1
    fi

    commits_ahead=$(command git $git_params rev-list --count "${other_branch}..${cur_branch}")
    commits_behind=$(command git $git_params rev-list --count "${cur_branch}..${other_branch}")

    echo "$cur_branch is $commits_ahead commits ahead of ${other_branch}, $commits_behind behind."
}

alias git-ahead-behind="get_branch_ahead_behind"

