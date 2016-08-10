#!/bin/bash

pattern=
exclude="^$"

substitutes="s/[(]//"

while [ $# -gt 0 ]
do
  case "$1" in
    -p) pattern="$2"; shift;;
    -s) substitutes="$substitutes;s/$2/"; shift;;
    -*)
       echo >&2 \
         "usage: $0 [-p pattern]"
       exit 1;;
     *) break;; # terminate while loop
  esac
  shift
done

case "$pattern" in
                  "go") pattern="[.]go$"
                        exclude="\([.]pb[.]go\|[.]pb[.]gw[.]go\)$"
                        ;;
  "go-test"|"go-tests") pattern="_test[.]go$" 
                        ;;
          "go-product") pattern="[.]go$"
                        exclude="_test[.]go$"
                        ;;
                    "") pattern=".*"
                        ;;
                     *) ;;
esac

echo run fame with pattern: $pattern and exclude: $exclude

git ls-files | grep -e "$pattern" | grep -ve "$exclude" \
  | xargs -L 1 git annotate --minimal -M -C -w -e -s | awk ' { print $2 } ' | sed "$substitutes" \
  | sort | uniq -c | sort -n
