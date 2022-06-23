#!/usr/bin/env bash

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

    TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | grep "^feature/\|^release/"`
    if [ ! -z "$TARGET_BRANCH" ]
    then
        echo "${TARGET_BRANCH}"
        return
    fi

    git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@"
}

new_branch()
{
    NEW_BRANCH=$1
    TARGET_BRANCH=

    # Check if the new branch does not have explicit target
    if [[ ${NEW_BRANCH} != *"@"* ]]
    then
        TARGET_BRANCH=`target_branch`
        if [ "${TARGET_BRANCH}" == $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@") ]
        then
            TARGET_BRANCH=
        else
            TARGET_BRANCH=@${TARGET_BRANCH}
        fi
    fi
    git checkout -b ${NEW_BRANCH}${TARGET_BRANCH}
}

ggb()
{
  git grep -n "$1" | while IFS=: read i j k; do git blame --porcelain -f -L $j,$j $i; done | grep "author " | sort | uniq -c | sort -k 1
}

remote_branch()
{
  BRANCH=$1
  git checkout origin/$BRANCH -b $BRANCH
}

alias gtr='git commit --allow-empty --allow-empty-message -m "" && git push'
alias gcam='git commit -am'
alias gsh='git show'
alias gbr='git branch'
alias gco='git checkout'
alias gcob='new_branch'
alias gcor='remote_branch'
alias gcod='git checkout `git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@"`'
alias gcot='git checkout `target_branch`'
alias gam='git commit --all --amend --no-edit --allow-empty-message --allow-empty'
alias gpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`'
alias gsq="$BASEDIR/dev-scripts/git/squish.sh"
alias grr='git reset --hard HEAD~10 && git pull'

