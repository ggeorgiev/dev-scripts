#!/bin/bash

git ls-files | xargs -L 1 git annotate --minimal -M -C -w -e -s | awk ' { print $2 } ' | sort | uniq -c | sed 's/[(]//' | sort -n
