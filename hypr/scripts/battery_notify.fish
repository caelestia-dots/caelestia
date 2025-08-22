#!/usr/bin/env fish

while true
    set capacity (cat /sys/class/power_supply/BAT0/capacity)
    set bat_status (cat /sys/class/power_supply/BAT0/status)

    if test $capacity -le 15 -a "$bat_status" = "Discharging"
        notify-send -u critical "Battery Low" "Battery at $capacity%"
    end

    sleep 60
end

