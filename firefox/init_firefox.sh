#!/usr/bin/env bash

firefox --headless about:blank &>/dev/null &
ff_pid=$!

# Wait for the profiles.ini but stop if Firefox dies or time out
tries=0
while [[ ! -f "${HOME}/.mozilla/firefox/profiles.ini" ]]; do
    kill -0 "$ff_pid" 2>/dev/null || exit 0
    (( tries++ >= 30 )) && break
    sleep .5
done
sleep .5

kill "$ff_pid" 2>/dev/null
