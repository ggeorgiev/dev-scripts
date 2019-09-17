#!/usr/bin/env bash

# Have you ever get in a big mess in a branch, merges, changes,
# merges again, changes again.
#
# squish.sh is a script that can help. It squishes all the 
# differences in the current branch from master in a single
# change.

function status
{
  STATUS=`hub ci-status $1`
  if [ "$STATUS" == "no status" ]; then
    STATUS="[0minactive"
  else
    PR=`hub pr list -h $1`
    if [ -z "$PR" ]; then
      STATUS="[32m✔mmerged"
    fi
  fi

  LINKS=
  if [ "$STATUS" == "failure" ]; then
    STATUS=[31m✖failure
    LINKS=`hub ci-status -v $1 | grep "✖" | awk '{ print $3 }' | tr '\n' ' '`
  fi

  if [ "$STATUS" == "pending" ]; then
    STATUS=[33m●pending
    LINKS=`hub ci-status -v $1 | grep "●" | awk '{ print $3 }' | tr '\n' ' '`
  fi

  if [ "$STATUS" == "success" ]; then
    STATUS=[92m⊕success
  fi


  printf "\x1B%-9s \x1B[0m%-60s $LINKS\n" "$STATUS" "$1"
  return 0
}

export -f status

git branch | cut -c 3- | xargs -I {} sh -c "status {}" | sort

