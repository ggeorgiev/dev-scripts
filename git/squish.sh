#!/usr/bin/env bash

# Have you ever get in a big mess in a branch, merges, changes,
# merges again, changes again.
#
# squish.sh is a script that can help. It squishes all the 
# differences in the current branch from the default branch in a single
# change.

# TODO: restore the state if something goes wrong

DEFAULT_BRANCH=`git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@"`
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

if [ -z "$SQUISH_PULL_BRANCHES_PATTERN" ]
then
  SQUISH_PULL_BRANCHES_PATTERN="^${DEFAULT_BRANCH}|^feature/|^release/"
fi

# If there is no pull branch explicitly specified, try to obtain it from the branch name
if [ -z "$PULL_BRANCH" ]
then
    PULL_BRANCH=`echo $CURRENT_BRANCH | sed -e "s/^[^@]*//" | grep @ | cut -c 2-`
fi

if [ -z "$PULL_BRANCH" ]
then
  PULL_BRANCHS=( `git branch | cut -c 3- | grep -E $SQUISH_PULL_BRANCHES_PATTERN` )

  if [ ${#PULL_BRANCHS[@]} == 0 ]
  then
    echo "There is no branch that matches the pattern: $SQUISH_PULL_BRANCHES_PATTERN"
    exit 1
  fi

  if [ ${#PULL_BRANCHS[@]} == 1 ]
  then
    PULL_BRANCH=${PULL_BRANCHS[0]}
  else
    echo '*** There are multiple branches that match the pattern. Defaulting to ${DEFAULT_BRANCH}.'
    PULL_BRANCH=${DEFAULT_BRANCH}
  fi
fi 

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

MESSAGE=$1
if [[ -z "$MESSAGE" ]]
then
  MESSAGE=`git log -1 --grep '.' --cherry-pick --oneline --no-merges --right-only --pretty=%B ${PULL_BRANCH}...${CURRENT_BRANCH}`

  if [ -z "$MESSAGE" ]
  then
    MESSAGE="All changes from ${CURRENT_BRANCH} squished"
  fi
fi

echo Checking out ${PULL_BRANCH} ...
execute "git checkout ${PULL_BRANCH}" || exit 1
execute "git pull" || exit 1

echo Creating temporary branch ...
execute "git checkout -b ${TEMP_BRANCH}" || exit 1

echo Merging the changes from ${CURRENT_BRANCH} ...
execute "git merge --no-verify --no-edit ${CURRENT_BRANCH}" || exit 1

echo Reset back to the ${PULL_BRANCH} head ...
execute "git reset ${PULL_BRANCH}" || exit 1

if [ ! -z $POST_PROCESS_SQUISH ]
then
    echo post process the merge
    eval $POST_PROCESS_SQUISH
fi

execute "git add --intent-to-add `git rev-parse --show-toplevel`" || exit 1

if git diff --exit-code > /dev/null
then
    echo "All changes already in ${PULL_BRANCH}"

    execute "git checkout ${PULL_BRANCH}" || exit 1

    echo Deleting the current branch ...
    execute "git branch -D ${CURRENT_BRANCH}" || exit 1

    echo Deleting the temporary branch ...
    execute "git branch -D ${TEMP_BRANCH}" || exit 1

    exit 0
fi

execute "git add `git rev-parse --show-toplevel`" || exit 1

echo Check for conflicts ...
FILES=`git diff-index --cached --name-only HEAD`

IFS=$'\n'
for file in $FILES
do
    if [ -e "${file}" ]
    then
        if grep -nr "^<\{7\} \|^=\{7\}\|^>\{7\} " "${file}"
        then
            echo unstage $file
            execute "git reset HEAD $file"
        fi
    fi
done

echo Committing the changes with message "${MESSAGE}" ...
execute "git commit --allow-empty --no-verify -m \"${MESSAGE}\"" || exit 1

echo Deleting ${CURRENT_BRANCH} ...
execute "git branch -D ${CURRENT_BRANCH}" || exit 1

echo Moving the temporary branch to ${CURRENT_BRANCH} ...
execute "git checkout -b ${CURRENT_BRANCH}" || exit 1

echo Deleting the temporary branch ...
execute "git branch -D ${TEMP_BRANCH}" || exit 1

