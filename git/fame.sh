#!/bin/bash

pattern=
include=
order="sort -n"
filter="^$"
substitutes="s/[(]//"
exclude="\$nothing"
average=false
range=
limit=0

while [ $# -gt 0 ]
do
  case "$1" in
    -p) pattern="$2"; shift;;
    -s) substitutes="$substitutes;s/$2/"; shift;;
    -i) include="$include\|$2"; shift;;
    -e) exclude="$exclude\|$2"; shift;;
    -a) order="sort -k 2";;
    -g) average="true";;
    -r) range="--since=$2"; shift;;
    -l) limit=$2; shift;;
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

if [ -z "$include" ]
then
  include='.*'
else
  include=`echo $include | cut -c 3-`
fi

echo pattern: "$pattern" and filter: "filter" order: $order include: "$include" exclude: "$exclude" range: "$range"

STATS=`{
    (git log --format='<%aE>' | grep -v "$exclude" | grep "$include" | sort -u);
    (git ls-files | grep -e "$pattern" | grep -ve "filter" \
        | xargs -L 1 git annotate --minimal -M -C -w -e -s -b ${range} \
        | grep -v "^           " \
        | awk ' { print $2 } ' \
        | grep -v "$exclude" \
        | grep "$include" \
        | sed "$substitutes")
} | sort | uniq -c | $order | awk ' { print $1-1" "$2 } ' | awk '($1 >= '"$limit"')'`

echo "$STATS"

if [ "$average" == "true" ]
then
    echo "$STATS" | awk '{ total += $1 } END { print total/NR" <average@"NR">" }'
fi