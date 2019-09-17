#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

# Requires `brew install hub`

alias ghbr='hub pr show'
alias ci='hub ci-status'
alias cia='"$BASEDIR/dev-scripts/github/cia.sh"'
alias ghpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`; CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`;  TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/^\([^@]*\)$/\1@master/" | sed -e "s/^.*@//"`; MESSAGE=`git log -1 --grep '.' --cherry-pick --oneline --no-merges --right-only --pretty=%B master...$CURRENT_BRANCH`; hub pull-request -h $CURRENT_BRANCH -b $TARGET_BRANCH -m "$MESSAGE"'
alias ghm='git log -1 --grep '.' --cherry-pick --oneline --no-merges --right-only --pretty=%B master...`git rev-parse --abbrev-ref HEAD`'
