#!/bin/fish

set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -l config_path $config/caelestia/hypr.json

inotifywait -e 'close_write,moved_to,create' -m (dirname $config_path) | while read dir events file
    test "$dir$file" = $config_path && hyprctl reload
end
