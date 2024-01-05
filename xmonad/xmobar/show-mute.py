#!/usr/bin/python
import subprocess
import re

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return(result.stdout.strip())

status = run_command("pactl get-source-mute 1")

if(status == "Mute: no"):
    print(\033[96m+""+\033[00m)

else:
    print("")
