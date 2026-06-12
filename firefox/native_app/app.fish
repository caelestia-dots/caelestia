#!/usr/bin/env fish

function message -a msg
    # The message length as 4 hex bytes
    set -l x (printf '%08X' (string length -- $msg))
    # Write each of the 4 bytes
    printf '%b' "\\x$(string sub -s 7 -l 2 $x)\\x$(string sub -s 5 -l 2 $x)\\x$(string sub -s 3 -l 2 $x)\\x$(string sub -s 1 -l 2 $x)"
    # Write the message itself
    printf '%s' $msg
end

set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
set -l state_dir $state/caelestia
set -l scheme_path $state_dir/scheme.json

message (jq -c . $scheme_path)

inotifywait -q -e 'close_write,moved_to,create' -m $state_dir | while read dir events file
    test "$dir$file" = $scheme_path && message (jq -c . $scheme_path)
end
