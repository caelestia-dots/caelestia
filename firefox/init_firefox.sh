#!/usr/bin/env bash

profiles_ini="${HOME}/.mozilla/firefox/profiles.ini"

# Profiles already exist
[[ -f "$profiles_ini" ]] && exit 0

# Launch firefox to generate profiles
MOZ_NO_REMOTE=1 firefox --headless --no-remote about:blank &>/dev/null &
ff_pid=$!

# Wait for the profiles.ini but stop if Firefox dies or time out
tries=0
while [[ ! -f "$profiles_ini" ]]; do
    kill -0 "$ff_pid" 2>/dev/null || break
    (( tries++ >= 60 )) && break
    sleep .5
done

kill "$ff_pid" 2>/dev/null
wait "$ff_pid" 2>/dev/null
