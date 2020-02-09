#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

# Requires `brew install hub`

alias ghbr='hub pr show'
alias ci='hub ci-status'
alias cia='"$BASEDIR/dev-scripts/github/cia.sh"'
alias ghpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`; CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`;  TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/^\([^@]*\)$/\1@master/" | sed -e "s/^.*@//"`; MESSAGE=`git log -1 --grep '.' --cherry-pick --oneline --no-merges --right-only --pretty=%B master...$CURRENT_BRANCH`; hub pull-request -h $CURRENT_BRANCH -b $TARGET_BRANCH -m "$MESSAGE"'
alias ghm='git log -1 --grep '.' --cherry-pick --oneline --no-merges --right-only --pretty=%B master...`git rev-parse --abbrev-ref HEAD`'

retrigger() {
    FAILED=`hub ci-status -v -f "%t %S✔" $1 |\
            tr "✔" "\n" |\
            grep -v pending$ |\
            grep -v success$ |\
            grep -v code-review/reviewable |\
            grep -v "SonarQube Code Analysis" |\
            awk '{ print $1 }' |\
            tr '\n' ','`

    if [ -z "$FAILED" ]
    then
        echo "Nothing to re-trigger"
        return
    fi

    HEAD=
    if [ ! -z "$1" ]
    then
        HEAD="-h $1"
    fi

    PR=`hub pr show -f "%I" $HEAD`

    echo "retrigger $FAILED for pr $PR"

    github-commenter \
        -type pr\
        -comment "trigger $FAILED" \
        -number $PR \
        -repo `git config --get remote.origin.url | sed 's/.*:.*[/]\(.*\)[.]git/\1/'` \
        -owner `git config --get remote.origin.url | sed 's/.*:\(.*\)[/].*[.]git/\1/'` \
        -token `cat ~/.config/hub | grep oauth_token | awk '{ print $2 }'`
}

alias ret='retrigger'