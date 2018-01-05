#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

# Requires `brew install hub`

alias ghbr='hub browse'
alias ci='hub ci-status'
alias cia='git branch | cut -c 3- | xargs -I {} sh -c "echo {}; hub ci-status -v {}" | awk "NR%2{printf \"%s \",\$0;next;}1" | sed "s/no status/inactive:/" | awk "{ printf(\"%-9s %-60s - %s\n\", \$2, \$1, \$3); }" | sed "s/^\(success: *[^ ]*\).*$/\1/;s/^\(inactive: *[^ ]*\).*$/\1/" | sort'
alias ghpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`; CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`;  TARGET_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/^\([^@]*\)$/\1@master/" | sed -e "s/^.*@//"`; MESSAGE=`git log -1 --cherry-pick --oneline --no-merges --right-only --pretty=%B master...$CURRENT_BRANCH`; hub pull-request -h $CURRENT_BRANCH -b $TARGET_BRANCH -m "$MESSAGE"'
alias ghm='git log -1 --cherry-pick --oneline --no-merges --right-only --pretty=%B master...`git rev-parse --abbrev-ref HEAD`'