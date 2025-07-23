#!/bin/fish

set -l src (dirname (status filename))
set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME/caelestia || set -l config $HOME/.config/caelestia

test -f $config/hypr.json && set -l style (jq -r '.hyprland.style' $config/hypr.json)
test -f "$src/templates/hyprland/$style.conf" || set -l style aesthetic

set -l template $src/templates/hyprland/$style.conf
set -l dest $src/../hyprland/overrides.conf

if ! diff -qN $template $dest > /dev/null
    cp $template $dest
    hyprctl reload
end
