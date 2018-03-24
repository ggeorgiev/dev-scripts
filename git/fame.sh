#!/bin/bash

pattern=
order="sort -n"
filter="^$"
substitutes="s/[(]//"
exclude="\$nothing"
average=false

while [ $# -gt 0 ]
do
  case "$1" in
    -p) pattern="$2"; shift;;
    -s) substitutes="$substitutes;s/$2/"; shift;;
    -e) exclude="$exclude\|$2"; shift;;
    -a) order="sort -k 2";;
    -g) average="true";;
    -*)
       echo >&2 \
         "unknown argument: $1" \
         "usage: $0 [-p pattern]"
       exit 1;;
     *) break;; # terminate while loop
  esac
  shift
done

case "$pattern" in
                      "go") pattern="[.]go$"
                            filter="\([.]pb[.]go\|[.]pb[.]gw[.]go\|[.]bin[.]go\|[.]avro[.]go\)$"
                            ;;
      "go-test"|"go-tests") pattern="_test[.]go$"
                            ;;
              "go-product") pattern="[.]go$"
                            filter="_test[.]go$"
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

echo include: "$pattern" and filter: "filter" order: $order exclude: "$exclude"

STATS=`{
    (git log --format='<%aE>' | grep -v "$exclude" | sort -u);
    (git ls-files | grep -e "$pattern" | grep -ve "filter" \
        | xargs -L 1 git annotate --minimal -M -C -w -e -s | awk ' { print $2 } ' | grep -v "$exclude" | sed "$substitutes")
} | sort | uniq -c | $order | awk ' { print $1-1" "$2 } '`

echo "$STATS"

if [ "$average" == "true" ]
then
    echo "$STATS" | awk '{ total += $1 } END { print total/NR" <average@"NR">" }'
fi