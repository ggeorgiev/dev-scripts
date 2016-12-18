#!/bin/sh

go get golang.org/x/tools/cmd/goimports
find . \( -type d -name vendor -prune -a -type f \) -o -type f -name "*.go" | xargs gofmt -w -s
find . \( -type d -name vendor -prune -a -type f \) -o -type f -name "*.go" | xargs goimports -w

if [ ! -z "`which clang-format`" ]
then
    find . \( -type d -name vendor -prune -a -type f \) -o -name "*.proto" | xargs clang-format -i
fi

