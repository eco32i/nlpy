#!/bin/bash

cat $HOME/.i3/config.common > $HOME/.i3/config
if [ -f $HOME/.i3/config.local ]
then
    cat $HOME/.i3/config.local >> $HOME/.i3/config
fi

exec /usr/bin/i3
