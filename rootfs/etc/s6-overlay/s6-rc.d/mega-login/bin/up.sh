#!/usr/bin/env sh

: ${EMAIL}
: ${PASSWORD}

s6-sleep 1

export HOME=/root # TODO

/usr/bin/mega-exec login "$EMAIL" "$PASSWORD"
