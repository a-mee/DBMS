#!/bin/bash
#check parameters given
if [ $# -ne 3 ] && [ $# -ne 2 ]; then
    echo "Error: parameters problem"
    exit 1
fi
#add database lock
while ! ln "$0" "$1-lock" 2>/dev/null; do
        sleep 1
done
#check database and table exist
if [ ! -d "$1" ]; then
    echo "Error: DB does not exist"
    rm "$1-lock"
    exit 2
elif [ ! -e "$1"/"$2" ]; then
    echo "Error: table does not exist"
    rm "$1-lock"
    exit 3
else
#count number of columns in table
    colCount=0
    Fline="$(head -1 "$1"/"$2")"
    fileArray="($(echo "$Fline" | tr "," "\n"))"
    for i in $fileArray; do
        colCount="$((colCount + 1))"
    done
#if no columns are given - select all columns
    if [ $# -eq 2 ]; then
        cols=""
        for ((i=1;i<colCount;i++)); do
            cols+="$i,"
        done
        cols+="$colCount"
#if columns are given make sure they exist in the table
    else
        IFS=',' read -r -a parArray <<< "$3"
        len="${#parArray[@]}"
#check if the columns given are numbers or names of columns
        if [ "${parArray[1]}" -eq "${parArray[1]}" ] 2>/dev/null; then
#if numbers:
            for i in "${parArray[@]}"; do
                if [ "$i" -gt $colCount ] || [ "$i" -lt 1 ]; then
                    echo "Error: column does not exist"
                    rm "$1-lock"
                    exit 4
                fi
            done
            cols="$3"
#if column names:
        else
            cols=""
            nameCount=0
            for ((i=0;i<len-1;i++)); do
                count=0
                for c in $fileArray; do
                    count=$((count+1))
                    if [ "${parArray[i]}" == "$c" ] || [ "${parArray[i]})" == "$c" ] || [ "(${parArray[i]}" == "$c" ]; then
                        cols+="$count,"
                        nameCount=$((nameCount+1))
                    fi
                done
            done
            count=0
            for c in $fileArray; do
                count=$((count+1))
                if [ "${parArray[len-1]}" == "$c" ] || [ "${parArray[len-1]})" == "$c" ] || [ "(${parArray[len-1]}" == "$c" ]; then
                    cols+="$count"
                    nameCount=$((nameCount+1))
                fi
            done
            if [ "$nameCount" -ne "$len" ]; then
                echo "Error: column name does not exist"
                rm "$1-lock"
                exit 4
            fi
        fi
    fi
#return result
    IFS=',' read -r -a colsArray <<< "$cols"
    rCount=0
    for a in "${colsArray[@]}"; do
        rCount=$((rCount+1))
        cut -d',' -f"$a" "$1"/"$2" >> "result_$rCount"
    done
    x=()
    for ((i=1;i<=rCount;i++)); do
        x+=("result_$i")
    done
    paste -d',' "${x[@]}" > result

    echo "start_result"
    while read -r output; do
        echo "$output"
    done < result
    echo "end_result"
    rm result
    rm "${x[@]}"
    rm "$1-lock"
    exit 0
fi
