#!/usr/bin/env bash

alias bb='bazel build'
alias bt='bazel test'
alias bq='bazel query'

alias bba='bazel build //...'
alias bta='bazel test //...'
alias bqa='bazel query //...'

alias brg='bazel run --remote_download_toplevel //:gazelle-runner'
alias brgr='bazel run --remote_download_toplevel //:gazelle-update-repos-runner && bazel run --remote_download_toplevel //:gazelle-runner'



