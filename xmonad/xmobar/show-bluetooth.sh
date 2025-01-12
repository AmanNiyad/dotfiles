#!/bin/bash
set -x
# Replace with the MAC address of your Bluetooth device
 #DEVICE_MAC=$(bluetoothctl list | cut -d\  -f2)

# Check if Bluetooth service is active
    # Bluetooth is active, check connection status
if bluetoothctl info "$DEVICE_MAC" | grep -q "Connected: yes"; then
    # Device is connected
    echo "<fc=#7682e8><fn=2>󰂰</fn></fc>"
else
    # Device is not connected
    echo "<fc=#f44336><fn=2>󰂲</fn></fc>"
fi
