#!/bin/sh
find . -name "*.go" | xargs gofmt -w -s
find . -name "*.go" | xargs goimports -w
