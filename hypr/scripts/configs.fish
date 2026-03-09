#!/usr/bin/env fish

set -l _reload false

# Ensure config directory exists
if ! test -d $argv
    mkdir -p $argv
end

# Ensure hypr-vars exists
if ! test -f $argv/hypr-vars.conf
    touch -a $argv/hypr-vars.conf
    set -l _reload true
end

# Ensure hypr-user exists
if ! test -f $argv/hypr-user.conf
    touch -a $argv/hypr-user.conf
    set -l _reload true
end

# Reload as needed
if _reload
    hyprctl reload
end
