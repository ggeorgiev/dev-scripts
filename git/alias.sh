#!/bin/bash
pushd `dirname ${BASH_ARGV[0]}`/../.. > /dev/null && BASEDIR=$(pwd -L) && popd > /dev/null

alias gbr='git branch'
alias gco='git checkout'
alias gam='git commit --all --amend --no-edit'
alias gpr='git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`'
alias gsq="$BASEDIR/dev-scripts/git/squish.sh"

