#!/bin/sh

#go imports seems to do not touch empty lines in the import section
find . \( -type d -name vendor -prune -a -type f \) -o -type f -name "*.go" | xargs -L 1 sed -i '' '/^import (/,/^[[:space:]]*)/ { /^[[:space:]]*$/ d; }'

find . \( -type d -name vendor -prune -a -type f \) -o -type f -name "*.go" | xargs go tool fix

go get golang.org/x/tools/cmd/goimports
find . \( -type d -name vendor -prune -a -type f \) -o -type f -name "*.go" | xargs gofmt -w -s
find . \( -type d -name vendor -prune -a -type f \) -o -type f -name "*.go" | xargs goimports -w

if [ ! -z "`which clang-format`" ]
then
    find . \( -type d -name vendor -prune -a -type f \) -o -name "*.proto" | xargs clang-format -i
fi

