#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 DIRECTORY" >&2
  exit 1
fi

REPO=$1
find $GOPATH/src -path $REPO -prune -o \( -type f -o -type l \) -print | xargs -I{} rm "{}"

while [ `find $GOPATH -type d -empty | wc -l` != 0 ]
do
    find $GOPATH -type d -empty | xargs -L 1 rmdir
done
