#!/bin/sh
# Sync with mbsync, then wait and do it again.
#
# Env:
#   MBSYNC_INTERVAL  seconds between runs, default 300
set -u

interval="${MBSYNC_INTERVAL:-300}"
sleep_pid=''

# A plain "sleep" in the loop left the container unstoppable: sh does not run
# traps while a foreground child is running, so SIGTERM was ignored and every
# "docker stop" had to wait out its timeout and SIGKILL. Sleeping in the
# background and waiting on it makes the signal land immediately.
stop() {
    if [ -n "$sleep_pid" ]; then
        kill "$sleep_pid" 2>/dev/null || true
    fi
    exit 0
}
trap stop TERM INT

while true; do
    # A failed sync is not fatal: mail servers time out, and the next pass in
    # ${interval}s is the retry.
    mbsync "$@" || echo "$0: mbsync failed, retrying in ${interval}s" >&2

    sleep "$interval" &
    sleep_pid=$!
    wait "$sleep_pid" 2>/dev/null || true
    sleep_pid=''
done
