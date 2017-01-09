#!/bin/sh

find $GOPATH/src -path `git rev-parse --show-toplevel` -prune -o -type f -print | xargs -L 1 rm

while [ `find $GOPATH -type d -empty | wc -l` != 0 ]
do
    find $GOPATH -type d -empty | xargs -L 1 rmdir
done
