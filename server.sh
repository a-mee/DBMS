#!/bin/bash

#trap ctrl + c
trap ctrl_c INT
function ctrl_c() {
    rm server.pipe
    exit 0
}
#make server pipe
if [[ ! -p server.pipe ]]; then
    mkfifo server.pipe
fi

while true; do
#read from server pipe
    while read -r input; do
#seperate the parameters
        command=$(echo "$input"| cut -d' ' -f 1)
        id=$(echo "$input"| cut -d' ' -f 2)
        params=${input#"$command $id"}
	IFS=' ' read -r -a paramsArray <<< "$params"
#call the right command script
        if [ "$command" == "create_database" ]; then
            { ./create_database.sh "${paramsArray[@]}" & } > "$id".pipe
        elif [ "$command" == "create_table" ]; then
            { ./create_table.sh "${paramsArray[@]}" & } > "$id".pipe
        elif [ "$command" == "insert" ]; then
            { ./insert.sh "${paramsArray[@]}" & } > "$id".pipe
        elif [ "$command" == "select" ]; then
            { ./select.sh "${paramsArray[@]}" & } > "$id".pipe
#shutdown
	elif [ "$command" == "shutdown" ]; then
            rm server.pipe
            exit 0
	else
            echo "Error: bad request"
            rm server.pipe
            exit 1
        fi
    done < server.pipe
done
