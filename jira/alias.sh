#!/usr/bin/env bash

pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

alias jlip='jira issues list -s"In Progress" -a `jira me`'
alias jdmi='jira issues list -q "summary ~ \"Maintain `git remote get-url origin | sed -n "s/^.*\/\(.*\)\.git$/\1/p"`\"" -a `jira me` --plain --columns="key" --no-headers --no-truncate'