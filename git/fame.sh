#!/bin/bash

pattern=
order="sort -n"
exclude="^$"
substitutes="s/[(]//"

while [ $# -gt 0 ]
do
  case "$1" in
    -p) pattern="$2"; shift;;
    -s) substitutes="$substitutes;s/$2/"; shift;;
    -a) order="sort -k 2";;
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
                            exclude="\([.]pb[.]go\|[.]pb[.]gw[.]go\|[.]bin[.]go\|[.]avro[.]go\)$"
                            ;;
      "go-test"|"go-tests") pattern="_test[.]go$"
                            ;;
              "go-product") pattern="[.]go$"
                            exclude="_test[.]go$"
                            ;;
                    "java") pattern="[.]java$"
                            ;;
  "java-test"|"java-tests") pattern='/test/java/.*[.]java$'
                            ;;
            "java-product") pattern='/main/java/.*[.]java$'
                            ;;
                        "") pattern=".*"
                            echo case $pattern
                            ;;
                         *) ;;
esac

echo include: "$pattern" and exclude: "$exclude" order: $order

{
    (git log --format='<%aE>' | sort -u);
    (git ls-files | grep -e "$pattern" | grep -ve "$exclude" \
        | xargs -L 1 git annotate --minimal -M -C -w -e -s | awk ' { print $2 } ' | sed "$substitutes")
} | sort | uniq -c | $order | awk ' { print $1-1" "$2 } '
