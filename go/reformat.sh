#!/bin/sh
find . -name *.go | xargs gofmt -w -s
