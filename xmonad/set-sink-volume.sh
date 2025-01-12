#!/bin/bash
set -x
# Get the default sink
DEFAULT_SINK=$(pactl info | grep "Default Sink" | awk '{print $3}')

DEFAULT_SOURCE=$(pactl info | grep "Default Source" | awk '{print $3}')
# Set volume or toggle mute
if [[ $1 == "up" ]]; then
    pactl set-sink-volume "$DEFAULT_SINK" +2%
elif [[ $1 == "down" ]]; then
    pactl set-sink-volume "$DEFAULT_SINK" -2%
elif [[ $1 == "toggle-mute" ]]; then
    pactl set-source-mute "$DEFAULT_SOURCE" toggle
fi

