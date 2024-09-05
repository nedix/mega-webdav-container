#!/usr/bin/env sh

: ${MEGA_IP}
: ${MEGA_PORT}

setsid /opt/mega-webdav/mitmproxy/mitmdump.py \
    --set "flow_detail=1" \
    --set "termlog_verbosity=error" \
    --set "listen_host=0.0.0.0" \
    --set "listen_port=80" \
    --mode "reverse:http://${MEGA_IP}:${MEGA_PORT}" \
    --set "keep_host_header=true" \
    --set "stream_large_bodies=32m" \
    -s "/opt/mega-webdav/mitmproxy/scripts/fix-directory-move.py" \
    -s "/opt/mega-webdav/mitmproxy/scripts/fix-directory-timestamps.py"
