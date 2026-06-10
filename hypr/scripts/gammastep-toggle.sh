#!/bin/bash

LOG_FILE="$HOME/.config/hypr/scripts/gammastep.log"
exec >> "$LOG_FILE" 2>&1

echo "------------------------------"
echo "Time: $(date)"

# Ensure environment
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

APP_NAME="Gammastep"
ICON_ON="weather-clear-night"
ICON_OFF="weather-clear"
ICON_ERROR="dialog-error"

# Prevent spam/race
LOCK_FILE="/tmp/gammastep-toggle.lock"
if [ -f "$LOCK_FILE" ]; then
    echo "Blocked: already running"
    exit 0
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

if pgrep -x gammastep > /dev/null; then
    echo "Stopping gammastep"
    pkill -x gammastep
    sleep 0.2
    notify-send -a "$APP_NAME" -i "$ICON_OFF" "Night Mode Disabled"
else
    echo "Starting gammastep"
    
    # Create a temporary file to capture immediate startup errors
    TMP_ERR_FILE=$(mktemp)
    
    # Launch gammastep in the background, redirecting stderr to our temp file
    gammastep -O 4500 > /dev/null 2> "$TMP_ERR_FILE" &
    GAMMASTEP_PID=$!
    
    # Wait briefly to let the process fully initialize or fail
    sleep 0.3
    
    # Check if the process died immediately after starting
    if ! kill -0 "$GAMMASTEP_PID" 2>/dev/null; then
        # Read the error message, fallback to generic if empty
        ERROR_MSG=$(cat "$TMP_ERR_FILE")
        if [ -z "$ERROR_MSG" ]; then
            ERROR_MSG="Process exited unexpectedly during startup."
        fi
        
        echo "Execution Failed: $ERROR_MSG"
        notify-send -a "$APP_NAME" -i "$ICON_ERROR" "Night Mode Failed" "$ERROR_MSG"
    else
        echo "Gammastep started successfully (PID: $GAMMASTEP_PID)"
        notify-send -a "$APP_NAME" -i "$ICON_ON" "Night Mode Enabled"
    fi
    
    # Clean up the temporary error file
    rm -f "$TMP_ERR_FILE"
fi

echo "Done"
