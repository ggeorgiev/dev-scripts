#!/usr/bin/env bash

# Have you ever get in a big mess in a branch, merges, changes,
# merges again, changes again.
#
# squish.sh is a script that can help. It squishes all the 
# differences in the current branch from master in a single
# change.

# TODO: restore the state if something goes wrong

#PULL_BRANCH=$1
#if [ -e "PULL_BRANCH" ]
#then 
    PULL_BRANCH=master
#fi

CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ "${CURRENT_BRANCH}" == "${PULL_BRANCH}" ]
then
  echo "You are already on ${PULL_BRANCH}"
  exit 1
fi

TEMP_BRANCH=${CURRENT_BRANCH}-temp

execute() {
  echo \ \ \ \ \$\ $1
  eval $1 2>&1 | awk '{ print "          " $0 }'
}

if [[ ! -z $(git status -s) ]]
then
  echo "Please commit all your changes first"
  exit 1
fi

echo Checking out ${PULL_BRANCH} ...
execute "git checkout ${PULL_BRANCH}" || exit 1
execute "git pull" || exit 1

echo Creating temporary branch ...
execute "git checkout -b ${TEMP_BRANCH}" || exit 1

echo Merging the changes from ${CURRENT_BRANCH} ...
execute "git merge --no-edit ${CURRENT_BRANCH}" || exit 1

echo Reset back to the ${PULL_BRANCH} head ...
execute "git reset ${PULL_BRANCH}" || exit 1

if [ ! -z $POST_PROCESS_SQUISH ]
then
    echo post precess the merge
    eval $POST_PROCESS_SQUISH
fi

MESSAGE=$1
if [[ -z "$MESSAGE" ]]
then
  MESSAGE="All changes from ${CURRENT_BRANCH} squished"
fi

echo Commiting the changes with message "${MESSAGE}" ...
execute "git add `git rev-parse --show-toplevel`" || exit 1
execute "git commit -m \"${MESSAGE}\"" || exit 1

echo Deleting ${CURRENT_BRANCH} ...
execute "git branch -D ${CURRENT_BRANCH}" || exit 1

echo Moving the temporary branch to ${CURRENT_BRANCH} ...
execute "git checkout -b ${CURRENT_BRANCH}" || exit 1

echo Deleting the temporary branch ...
execute "git branch -D ${TEMP_BRANCH}" || exit 1

