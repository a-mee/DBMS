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
elif [ -e "$1"/"$2" ]; then
    echo "Error: table already exists"
    rm "$1-lock"
    exit 3
else
    echo "$3" > "$1"/"$2"
    echo "OK: table created"
    rm "$1-lock"
    exit 0
fi