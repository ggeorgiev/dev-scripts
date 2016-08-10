#!/bin/sh

EMAIL=
NEW_EMAIL=
NEW_NAME=

while [ $# -gt 0 ]
do
  case "$1" in
    -r) EMAIL="$2"; shift;;
    -e) NEW_EMAIL="$2"; shift;;
    -a) NEW_NAME="$2"; shift;; 
    -*)
       echo >&2 \
         "usage: $0 -r email_to_replace [ -e new_email ] [ -n new_name ]"
       exit 1;;
     *) break;; # terminate while loop
  esac
  shift
done


git filter-branch --env-filter "

EMAIL=`echo $EMAIL`
NEW_EMAIL=`echo $NEW_EMAIL`
NEW_NAME=`echo $NEW_NAME` 

if [ \"\$GIT_COMMITTER_EMAIL\" = \"\$EMAIL\" ]
then
  if [[ ! -z \$NEW_NAME ]]
  then
    export GIT_COMMITTER_NAME=\"\$NEW_NAME\"
  fi
  if [[ ! -z \$NEW_EMAIL ]]
  then
    export GIT_COMMITTER_EMAIL=\"\$NEW_EMAIL\"
  fi
fi

if [ \"\$GIT_AUTHOR_EMAIL\" = \"\$EMAIL\" ]
then
  if [[ ! -z \$NEW_NAME ]]
  then
    export GIT_AUTHOR_NAME=\"\$NEW_NAME\"
  fi
  if [[ ! -z \$NEW_EMAIL ]]
  then
    export GIT_AUTHOR_EMAIL=\"\$NEW_EMAIL\"
  fi
fi

" -f --tag-name-filter cat -- --branches --tags
