#!/bin/bash

# Configuration
DISPLAY_NAME="eDP-1"                            # Change to your actual display name
STEP=0.05                                        # Brightness step
MIN_BRIGHTNESS=0.1
MAX_BRIGHTNESS=1.0
BRIGHTNESS_FILE="$HOME/.config/brightness"     # File to store brightness value

# Create config dir if it doesn't exist
mkdir -p "$(dirname "$BRIGHTNESS_FILE")"

# Read current brightness from xrandr or fallback to file
CURRENT=$(xrandr --verbose | grep -m 1 -i brightness | awk '{print $2}')

# If xrandr fails (e.g., on startup), use last saved value
if [ -z "$CURRENT" ]; then
    if [ -f "$BRIGHTNESS_FILE" ]; then
        CURRENT=$(cat "$BRIGHTNESS_FILE")
    else
        CURRENT=1.0
    fi
fi

# Decide action
case "$1" in
  up)
    NEW=$(echo "$CURRENT + $STEP" | bc)
    ;;
  down)
    NEW=$(echo "$CURRENT - $STEP" | bc)
    ;;
  set)
    NEW="$2"
    ;;
  restore)
    if [ -f "$BRIGHTNESS_FILE" ]; then
        NEW=$(cat "$BRIGHTNESS_FILE")
    else
        NEW=1.0
    fi
    xrandr --output $DISPLAY_NAME --brightness $NEW
    echo "Brightness restored to $NEW"
    exit 0
    ;;
  *)
    echo "Usage: $0 {up|down|set <value>|restore}"
    exit 1
    ;;
esac

# Clamp value
if (( $(echo "$NEW < $MIN_BRIGHTNESS" | bc -l) )); then
  NEW=$MIN_BRIGHTNESS
elif (( $(echo "$NEW > $MAX_BRIGHTNESS" | bc -l) )); then
  NEW=$MAX_BRIGHTNESS
fi

# Apply and save
xrandr --output $DISPLAY_NAME --brightness $NEW
echo "$NEW" > "$BRIGHTNESS_FILE"
echo "Brightness set to $NEW"

