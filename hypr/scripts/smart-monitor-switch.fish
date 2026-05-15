#!/bin/fish

# Smart Monitor Switch for Hyprland
# Automatically configures monitors based on what's connected:
# - 0 external: Laptop screen only
# - 1 external: Laptop + external at 60Hz
# - 2 external: External only at 30Hz (bandwidth limitation)

function count_external_monitors
    # Count connected monitors excluding eDP (laptop display)
    set -l count 0
    for status_file in /sys/class/drm/card*/status
        set -l name (basename (dirname $status_file))
        if test (cat $status_file) = "connected"
            if not string match -q "*eDP*" $name
                set count (math $count + 1)
            end
        end
    end
    echo $count
end

function get_external_monitors
    # Get names of external monitors from Hyprland
    hyprctl monitors -j | jq -r '.[] | select(.name | startswith("DP") or startswith("HDMI")) | .name'
end

function configure_monitors
    set -l external_count (count_external_monitors)
    set -l external_monitors (get_external_monitors)
    
    echo "Detected $external_count external monitor(s)"
    
    switch $external_count
        case 0
            # No external monitors - laptop only
            echo "Configuring laptop-only mode"
            hyprctl keyword monitor "eDP-2,2560x1600@165,0x0,1.25"
            
        case 1
            # One external monitor - laptop + external at 60Hz
            echo "Configuring laptop + single external mode"
            hyprctl keyword monitor "eDP-2,2560x1600@165,0x0,1.25"
            
            # Configure the external monitor at 60Hz
            for monitor in $external_monitors
                echo "Enabling $monitor at 60Hz"
                hyprctl keyword monitor "$monitor,3840x2160@60,3072x0,1"
            end
            
        case 2
            # Two external monitors - disable laptop, run at 30Hz for bandwidth
            echo "Configuring dual external mode (30Hz for MST bandwidth)"
            
            # Disable laptop
            hyprctl keyword monitor "eDP-2,disable"
            
            # Configure external monitors at 30Hz
            set -l position 0
            for monitor in $external_monitors
                echo "Enabling $monitor at 30Hz, position $position,0"
                hyprctl keyword monitor "$monitor,3840x2160@30,$position"x0",1"
                set position (math $position + 3840)
            end
            
        case '*'
            # More than 2 external monitors
            echo "More than 2 external monitors detected - using default configuration"
            # Let Hyprland handle it with auto config
    end
end

# Function to monitor for changes
function monitor_loop
    # Initial configuration
    configure_monitors
    
    echo "Monitoring for display changes..."
    
    # Monitor for changes
    while true
        # Use inotifywait on DRM directory for connection changes
        inotifywait -q -e create,delete,modify --timeout 5 /sys/class/drm/ 2>/dev/null
        
        # Small delay to let hardware stabilize
        sleep 2
        
        # Reconfigure monitors
        configure_monitors
    end
end

# Handle script arguments
if test (count $argv) -gt 0
    switch $argv[1]
        case "once"
            # Just configure once and exit
            configure_monitors
        case "daemon"
            # Run as daemon
            monitor_loop
        case '*'
            echo "Usage: $argv[0] [once|daemon]"
            echo "  once   - Configure monitors once and exit"
            echo "  daemon - Run continuously and monitor for changes"
            exit 1
    end
else
    # Default to daemon mode
    monitor_loop
end