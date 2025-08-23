#!/usr/bin/env fish

set last_capacity 100

while true
    set capacity (cat /sys/class/power_supply/BAT0/capacity)
    set bat_status (cat /sys/class/power_supply/BAT0/status)

    if test "$bat_status" = "Discharging"
        if test $capacity -le 15
            set diff (math "$last_capacity - $capacity")
            if test $capacity -eq 15 -o $capacity -eq 10 -o $capacity -eq 5 -o $capacity -eq 2 -o $capacity -eq 1 -o $diff -ge 5
                notify-send -u critical "Battery Low" "Battery at $capacity%"
                set last_capacity $capacity
            end
        end
    else
        set last_capacity 100
    end

    sleep 60
end
