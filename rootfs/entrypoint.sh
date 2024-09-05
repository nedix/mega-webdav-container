#!/usr/bin/env sh

: ${HOME_DIRECTORY}
: ${MEGA_EMAIL}
: ${MEGA_PASSWORD}
: ${ROOT_DIRECTORY}

MEGA_IP=127.0.0.1
MEGA_PORT=10000

# -------------------------------------------------------------------------------
#       Bootstrap mega services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #       Create mega-login environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mega-login/environment"

    echo "$MEGA_EMAIL"    > "/run/mega-login/environment/EMAIL"
    echo "$MEGA_PASSWORD" > "/run/mega-login/environment/PASSWORD"

    chmod -R 400 "/run/mega-login/environment"

    # -------------------------------------------------------------------------------
    #       Create mega-setup environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mega-setup/environment"

    echo "$ROOT_DIRECTORY" > "/run/mega-setup/environment/DIRECTORY"
    echo "$MEGA_IP"        > "/run/mega-setup/environment/IP"
    echo "$MEGA_PORT"      > "/run/mega-setup/environment/PORT"

    chmod -R 400 "/run/mega-setup/environment"
}

# -------------------------------------------------------------------------------
#       Bootstrap mitmdump services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #       Create mitmdump environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mitmdump/environment"

    echo "$MEGA_IP"   > "/run/mitmdump/environment/MEGA_IP"
    echo "$MEGA_PORT" > "/run/mitmdump/environment/MEGA_PORT"

    chmod -R 400 "/run/mitmdump/environment"
}

# -------------------------------------------------------------------------------
#    Create executables
# -------------------------------------------------------------------------------
for BIN in /etc/s6-overlay/s6-rc.d/*/bin/*.sh; do
    ENVIRONMENT=$(echo "$BIN" | sed "s|/etc/s6-overlay/s6-rc\.d/\(.*\)/bin/.*\.sh|/run/\1/environment|")
    SCRIPT=$(echo "$BIN" | sed "s|\(/etc/s6-overlay/s6-rc\.d/.*/\)bin/\(.*\)\.sh|\1\2|")
    SERVICE=$(echo "$BIN" | sed "s|/etc/s6-overlay/s6-rc\.d/\(.*\)/bin/.*\.sh|\1|")

    if [ -f "$SCRIPT" ]; then
        continue
    fi

    if [ -d "$ENVIRONMENT" ]; then
cat << EOF > "$SCRIPT"
#!/usr/bin/execlineb -P
exec s6-envdir "$ENVIRONMENT" "$BIN"
EOF
    else
cat << EOF > "$SCRIPT"
#!/usr/bin/execlineb -P
exec "$BIN"
EOF
    fi
done

# -------------------------------------------------------------------------------
#    Let's go!
# -------------------------------------------------------------------------------
exec env -i \
    PATH="/opt/mega-webdav/bin:${PATH}" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 120 * 1000 ))" \
    /init
