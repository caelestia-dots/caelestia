#!/bin/bash

LOG_FILE="$HOME/.config/hypr/scripts/suspend.log"
exec >> "$LOG_FILE" 2>&1

echo "------------------------------"
echo "Time: $(date)"

# Ensure environment paths for notifications
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

APP_NAME="System Power"
ICON_SLEEP="system-suspend-hibernate"
ICON_ERROR="dialog-error" # Standard system error warning icon

# Prevent double-press / rapid input spam
LOCK_FILE="/tmp/suspend-toggle.lock"
if [ -f "$LOCK_FILE" ]; then
    echo "Blocked: Suspension sequence already initiated"
    exit 0
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

echo "Initiating system suspend-then-hibernate sequence..."

# Send visual notification to screen immediately
notify-send -a "$APP_NAME" -i "$ICON_SLEEP" "Entering Deep Sleep" "Suspending to RAM, then hibernating..."

# Give the notification engine 1 second to draw the text before halting hardware
sleep 1.0

# 1. Run the command and capture stderr into a variable
# 2. Use '2>&1' to redirect standard error so bash can read it
ERROR_MSG=$(systemctl suspend-then-hibernate 2>&1)

# Check if the command failed
if [ $? -ne 0 ]; then
    echo "Execution Failed: $ERROR_MSG"
    
    # Send the real error message directly to your desktop monitor
    notify-send -a "$APP_NAME" -i "$ICON_ERROR" "Sleep Action Failed" "$ERROR_MSG"
else
    echo "System has woken back up safely."
fi

echo "Done"
