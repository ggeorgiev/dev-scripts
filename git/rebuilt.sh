#!/usr/bin/env bash

echo "This script does not work yet!!!"
exit 1

set -ex

ITEMS_PER_ITERATION=$1

REBUILT_TAG=rebuilt
REBUILT_MSG="The repo is already rebuilt up to here"

ALREADY_REBUILT_TAG=already_rebuilt
ALREADY_REBUILT_MSG="This is the last rebuilt change"

SCRIPT='find . -iname "*.java" | xargs clang-format -i'

AUTHORS=`cat ~/fix_authors.conf`

pause() {
    #read -p "Press any key to continue... " -n1 -s
}

git fetch origin
git reset origin/master --hard

pause

if git rev-parse $REBUILT_TAG >/dev/null 2>&1
then
    echo "Rebuilt tag found ... resume from there!!!"
else
    # There is no tag marking where we are already. Lets start from the begging.
    FIRST_SHA=`git rev-list --max-parents=0 HEAD`

    # Prepare the initial stage
    git reset --hard $FIRST_SHA

    pause

    git filter-branch -f \
        --tree-filter "$SCRIPT" \
        --tag-name-filter cat

    git tag -a $REBUILT_TAG -m "$REBUILT_MSG"
    git reset origin/master --hard

    git tag -a $ALREADY_REBUILT_TAG $FIRST_SHA -m "$ALREADY_REBUILT_MSG"

    pause
fi

NEXT_SHA=`git log --pretty=format:%H $ALREADY_REBUILT_TAG..HEAD | tail -$ITEMS_PER_ITERATION | head -n 1`
git reset --hard $NEXT_SHA

pause

git filter-branch -f \
    --parent-filter "sed s/`git rev-list -n 1 $ALREADY_REBUILT_TAG`/`git rev-list -n 1 $REBUILT_TAG`/g" \
    --tree-filter "$SCRIPT" \
    --commit-filter "$AUTHORS" \
    --tag-name-filter cat \
    -- $ALREADY_REBUILT_TAG..master

git tag -af $REBUILT_TAG -m "$REBUILT_MSG"
git tag -af $ALREADY_REBUILT_TAG $NEXT_SHA -m "$ALREADY_REBUILT_MSG"
