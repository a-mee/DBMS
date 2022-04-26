#!/bin/bash

IDPipe="$1".pipe

#trap ctrl + c
trap ctrl_c INT
function ctrl_c() {
    rm "$IDPipe"
    exit 0
}
#check parameter
if [ "$#" -ne 1 ]; then
    echo "Error: parameters problem"
    exit 1
fi

echo "Hello $1, welcome to the DBMS"

#make id pipe
if [[ ! -p "$IDPipe" ]]; then
    mkfifo "$IDPipe"
fi

#start server if is not already running
if [ ! -f server.pipe ]; then
        ./server.sh &
fi

while true; do
    echo "Please enter a command: "
#read input
    IFS= read -r input
#shutdown or end
    if [ "$input" == "exit" ]; then
        rm "$IDPipe"
	echo "Goodbye"
	exit 0
    elif [ "$input" == "shutdown" ]; then
        echo "shutdown" >> server.pipe
	echo "server has been shutdown, enter 'exit' if you would also like to exit client"
    else
#seperate the parameters and echo into server pipe
    	req=$(echo "$input"| cut -d' ' -f 1)
    	args=${input#"$req"}
    	outputArray=($req $1 $args)
#error check the command input
    	if [ "$req" == "create_database" ] || [ "$req" == "create_table" ] || [ "$req" == "insert" ] || [ "$req" == "select" ]; then
    	    echo "${outputArray[@]}" >> server.pipe

#read reply from ID pipe
    	    notSelect=true
    	    while read -r reply; do
            	if [ "$(echo "$reply"| cut -d' ' -f 1)" == "OK:" ]; then
            	    echo "command successfully executed"
		elif [ "$(echo "$reply"| cut -d' ' -f 1)" == "Error:" ]; then
		    echo "command executed but returned with an error"
            	elif [ "$reply" == "start_result" ]; then
            	    notSelect=false
            	elif [ "$notSelect" == false ]; then
            	    if [ "$reply" != "end_result" ]; then
                     	echo "$reply"
                    fi
            	fi
    	    done < "$IDPipe"
    	else
	    echo "Did not understand this command"
    	fi
    fi
done
