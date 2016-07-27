#!/bin/bash

git ls-files | xargs -L 1 git annotate -e -s | awk ' { print $2 } ' | sort | uniq -c | sed 's/[(]//' | sort -n
