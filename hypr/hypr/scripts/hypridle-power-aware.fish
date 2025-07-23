#!/usr/bin/env fish

# Check if AC adapter is connected
function is_on_ac_power
    # Check common AC adapter paths
    for ac in /sys/class/power_supply/AC* /sys/class/power_supply/ADP* /sys/class/power_supply/ACAD*
        if test -f "$ac/online"
            if test (cat "$ac/online") = "1"
                return 0
            end
        end
    end
    return 1
end

# Monitor power state changes
while true
    if is_on_ac_power
        # On AC power - kill hypridle if running
        if pgrep hypridle > /dev/null
            pkill hypridle
            echo "AC power connected - hypridle stopped"
        end
    else
        # On battery - start hypridle if not running
        if not pgrep hypridle > /dev/null
            hypridle &
            echo "On battery power - hypridle started"
        end
    end
    
    # Check every 5 seconds
    sleep 5
end