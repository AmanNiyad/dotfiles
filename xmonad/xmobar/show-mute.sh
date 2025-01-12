#!/bin/bash

set -x

DEFAULT_SOURCE=$(pactl info | grep "Default Source" | awk '{print $3}')
MUTE=$(pactl get-source-mute "$DEFAULT_SOURCE" | awk '{print $2}')

if [ $MUTE == 'yes' ]
then
    echo "<fc=#f44336></fc>"
else 
    echo "<fc=#cccccc></fc>"
fi
