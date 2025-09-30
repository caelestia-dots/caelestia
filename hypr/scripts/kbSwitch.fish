#!/usr/bin/env fish

set DEVICE (hyprctl devices -j | jq -r '.keyboards[0].name')
hyprctl switchxkblayout "$DEVICE" next
set LAYOUT (hyprctl devices -j | jq -r ".keyboards[] | select(.name == \"$DEVICE\") | .active_keymap")
qs -c caelestia ipc call toaster info "Keyboard layout switched" "Current layout: $LAYOUT" "keyboard"
