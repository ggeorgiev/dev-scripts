#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

new_branch()
{
    NEW_BRANCH=$1
    TARGET_BRANCH=

    # Check if the new branch does not have explicit target
    if [[ ${NEW_BRANCH} != *"@"* ]]
    then
        # Determine if we have to add one
        ## First lets check if the current branch have a target
        TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/^[^@]*//" | grep @`;

        # If it does not, maybe we are at the target branch itself. We should add it as target
        if [ -z "$TARGET_BRANCH" ]
        then
            TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | grep "^feature/" | awk '{ print "@"$1 }'`
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
alias gam='git commit --all --amend --no-edit'
alias gpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`'
alias gsq="$BASEDIR/dev-scripts/git/squish.sh"

