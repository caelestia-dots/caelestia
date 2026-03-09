#!/usr/bin/env fish

# Ensure config directory exists
if ! test -d $argv
    mkdir -p $argv
end

# Ensure hypr-vars exists
if ! test -f $argv/hypr-vars.conf
    touch -a $argv/hypr-vars.conf
end

# Ensure hypr-user exists
if ! test -f $argv/hypr-user.conf
    touch -a $argv/hypr-user.conf
end