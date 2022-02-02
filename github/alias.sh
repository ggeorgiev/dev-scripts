#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

# Requires `brew install gh`

alias ghbr='gh pr view --web'
alias ci='gh pr checks'
alias cia='"$BASEDIR/dev-scripts/github/cia.sh"'
alias ghpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`; CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`; DEFUALT_BRANCH=`git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@"`; TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/^\([^@]*\)$/\1@$DEFUALT_BRANCH/" | sed -e "s/^.*@//"`; MESSAGE=`git log -1 --grep '.' --cherry-pick --oneline --no-merges --right-only --pretty=%B $DEFUALT_BRANCH...$CURRENT_BRANCH`; gh pr create --head $CURRENT_BRANCH --base $TARGET_BRANCH --title "$MESSAGE" --body "."'
