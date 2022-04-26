#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Error: no parameter"
    exit 1
fi
if [ $# -ne 1 ]; then
    echo "Error: too many parameters"
    exit 2
fi

while ! ln "$0" "$1-lock" 2>/dev/null; do
        sleep 1
done

if [ -d "$1" ]; then
    echo "Error: DB already exists"
    rm "$1-lock"
    exit 3
else
    mkdir "$1"
    echo "OK: database created"
    rm "$1-lock"
    exit 0
fi