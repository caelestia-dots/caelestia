#!/usr/bin/env fish

# Poll cursor position and trigger notification history when hovering in top-right corner

set -l trigger_width 6
set -l trigger_height 6
set -l poll_ms 120

function get_monitors --description "Return active monitors as JSON"
    hyprctl -j monitors 2> /dev/null
end

function get_pointer --description "Return pointer coordinates"
    hyprctl -j cursorpos 2> /dev/null
end

function in_top_right --argument-names x y mon --description "Check if x,y in top-right of monitor"
    set -l mx (echo $mon | jq -r '.x')
    set -l my (echo $mon | jq -r '.y')
    set -l mw (echo $mon | jq -r '.width')
    set -l mh (echo $mon | jq -r '.height')

    set -l right_x (math $mx + $mw - $trigger_width)
    set -l top_y $my

    test $x -ge $right_x; and test $y -ge $top_y; and test $y -lt (math $top_y + $trigger_height)
end

function show_notifications --description "Open notification history/center"
    if command -v swaync-client > /dev/null
        swaync-client -t -o  # open/toggle notification center
        return
    end
    if command -v caelestia > /dev/null
        caelestia showall
        return
    end
    if command -v makoctl > /dev/null
        makoctl history
        return
    end
end

set -l last_trigger 0
while true
    set -l ptr (get_pointer)
    if test -z "$ptr"
        sleep (math $poll_ms / 1000)
        continue
    end
    set -l px (echo $ptr | jq -r '.x')
    set -l py (echo $ptr | jq -r '.y')

    set -l mons (get_monitors)
    for mon in (echo $mons | jq -c '.[]')
        if in_top_right $px $py $mon
            set -l now (date +%s)
            # Debounce to once per 1.5s
            if test (math $now - $last_trigger) -ge 1
                set last_trigger $now
                show_notifications &
            end
            break
        end
    end
    sleep (math $poll_ms / 1000)
end

