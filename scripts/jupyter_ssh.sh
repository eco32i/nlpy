#!/bin/bash -e

readonly autossh_exec=$(which autossh)
readonly remote="ilya@lab.nudlerlab.info"

if [ -z $autossh_exec ]
then
    echo "autossh not found. Exiting..."
    exit 1
fi

echo "$autossh_exec -R $1:localhost:$2 $remote -N &"
