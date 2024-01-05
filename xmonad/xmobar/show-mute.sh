#!/bin/bash

MUTE=$(pactl get-source-mute 1 | awk '{print $2}')

if [ $MUTE == 'yes' ]
then
    echo "<fc=#a00000></fc>"
else 
    echo "<fc=#cccccc></fc>"
fi
