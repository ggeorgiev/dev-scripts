#!/bin/sh

go get golang.org/x/tools/cmd/goimports
find . -name "*.go" | xargs gofmt -w -s
find . -name "*.go" | xargs goimports -w
