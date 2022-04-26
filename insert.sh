#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Error: parameters problem"
    exit 1
fi

while ! ln "$0" "$1-lock" 2>/dev/null; do
        sleep 1
done

if [ ! -d "$1" ]; then
    echo "Error: DB does not exist"
    rm "$1-lock"
    exit 2
elif [ ! -e "$1"/"$2" ]; then
    echo "Error: table does not exist"
    rm "$1-lock"
    exit 3
else
    colCount=0
    parCount=0

    Fline="$(head -1 "$1"/"$2")"
    fileArray="($(echo "$Fline" | tr "," "\n"))"
    for i in $fileArray; do
        colCount="$((colCount + 1))"
    done

    parArray="($(echo "$3" | tr "," "\n"))"
    for i in $parArray; do
        parCount="$((parCount + 1))"
    done

    if [ $colCount -ne $parCount ]; then
        echo "Error: number of columns in tuple does not match schema"
        rm "$1-lock"
        exit 4
    else
        echo "$3" >> "$1"/"$2"
        echo "OK: tuple inserted"
        rm "$1-lock"
        exit 0
    fi
fi