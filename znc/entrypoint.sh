#!/bin/sh

DATADIR="/znc-data"

if [ -d "${DATADIR}/modules" ]; then
    # znc-buildmod is not part of Alpine's znc package and needs a compiler, so
    # say why nothing was built instead of emitting "not found" for every source
    # file. Add znc-dev and build-base to the image if this is wanted.
    if command -v znc-buildmod >/dev/null 2>&1; then
        find "${DATADIR}/modules" -name '*.cpp' | while read -r module; do
            echo "Building module ${module}..."
            # A subshell for the cd, so a failure cannot leave the rest of the
            # loop running in the wrong directory.
            (cd "$(dirname "$module")" && znc-buildmod "$(basename "$module")") ||
                echo "Failed to build ${module}, skipping" >&2
        done
    else
        echo "${DATADIR}/modules exists but znc-buildmod is not installed;" >&2
        echo "skipping module builds" >&2
    fi
fi

if [ ! -f "${DATADIR}/configs/znc.conf" ]; then
    echo "Creating a default configuration..."
    mkdir -p "${DATADIR}/configs"
    cp /znc.conf.default "${DATADIR}/configs/znc.conf"
fi

exec znc --foreground --datadir="$DATADIR" "$@"
