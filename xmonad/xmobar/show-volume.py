#!/usr/bin/python

import subprocess
import re

allbars = "󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤󰝤"
emptybars = "               "

output = ""

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return(result.stdout.strip())

volume = int(re.findall(r'^\D*(\d+)', run_command("pactl get-sink-volume 0"))[0])

if(volume != 0):
    bars = int(volume / 6529)
    output = allbars[0:bars+1] + emptybars[bars+1:]

else:
    output = "     (mute)    "

print(output)
