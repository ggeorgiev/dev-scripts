#!/bin/sh

go get golang.org/x/tools/cmd/goimports
find . -name "*.go" | xargs goimports -w
