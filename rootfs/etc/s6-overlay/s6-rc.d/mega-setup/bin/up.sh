#!/usr/bin/env sh

: ${DIRECTORY}
: ${IP}
: ${PORT}

s6-sleep 1

ENDPOINT="$(
    export HOME=/root && \
    /usr/bin/mega-exec webdav --port="$PORT" --public "$DIRECTORY" \
    | awk '{print $NF}' \
    | sed "s|127.0.0.1|${IP}|"
)"

echo "ENDPOINT: $ENDPOINT"
