#!/bin/bash

# Get current transform of HDMI-A-1
current_transform=$(hyprctl monitors -j | jq -r '.[] | select(.name == "HDMI-A-1") | .transform')

if [ "$current_transform" = "3" ]; then
    # Currently portrait (270°), switch to landscape (0°)
    # In landscape: 1920x1080, position to align bottoms
    hyprctl keyword monitor HDMI-A-1,1920x1080@60,1600x-80,1.00,transform,0
else
    # Currently landscape (0°), switch to portrait (270°)
    # In portrait: rotated 90° CCW, position to align bottoms
    hyprctl keyword monitor HDMI-A-1,1920x1080@60,1600x-920,1.00,transform,3
fi
