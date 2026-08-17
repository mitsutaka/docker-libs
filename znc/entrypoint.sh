#!/usr/bin/env bash

DATADIR="/znc-data"

if [ -d "${DATADIR}/modules" ]; then
    cwd="$(pwd)"

    modules=$(find "${DATADIR}/modules" -name "*.cpp")

    for module in $modules; do
        echo "Building module $module..."
        cd "$(dirname "$module")" || exit 1
        znc-buildmod "$module"
    done

    cd "$cwd" || exit 1
fi

if [ ! -f "${DATADIR}/configs/znc.conf" ]; then
    echo "Creating a default configuration..."
    mkdir -p "${DATADIR}/configs"
    cp /znc.conf.default "${DATADIR}/configs/znc.conf"
fi

exec znc --foreground --datadir="$DATADIR" "$@"
