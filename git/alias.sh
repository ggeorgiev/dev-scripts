#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

target_branch()
{
    ## First lets check if the current branch have a target
    TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/^[^@]*//" | grep @ | cut -c 2-`
    if [ ! -z "$TARGET_BRANCH" ]
    then
        echo "${TARGET_BRANCH}"
        return
    fi

    TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | grep "^feature/"`
    if [ ! -z "$TARGET_BRANCH" ]
    then
        echo "${TARGET_BRANCH}"
        return
    fi

    echo "master"
}

new_branch()
{
    NEW_BRANCH=$1
    TARGET_BRANCH=

    # Check if the new branch does not have explicit target
    if [[ ${NEW_BRANCH} != *"@"* ]]
    then
        TARGET_BRANCH=`target_branch`
        if [ "${TARGET_BRANCH}" == "master" ]
        then
            TARGET_BRANCH=
        else
            TARGET_BRANCH=@${TARGET_BRANCH}
        fi
    fi
    git checkout -b ${NEW_BRANCH}${TARGET_BRANCH}
}

alias gtr='git commit --allow-empty --allow-empty-message -m "" && git push'
alias gcam='git commit -am'
alias gsh='git show'
alias gbr='git branch'
alias gco='git checkout'
alias gcob='new_branch'
alias gcom='git checkout master'
alias gcot='git checkout `target_branch`'
alias gam='git commit --all --amend --no-edit --allow-empty-message --allow-empty'
alias gpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`'
alias gsq="$BASEDIR/dev-scripts/git/squish.sh"

