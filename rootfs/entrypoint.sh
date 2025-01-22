#!/usr/bin/env sh

: ${HOME_DIRECTORY}
: ${MEGA_EMAIL}
: ${MEGA_PASSWORD}
: ${ROOT_DIRECTORY}
: ${STARTUP_TIMEOUT}

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

    # -------------------------------------------------------------------------------
    #       Create mega-setup environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mega-setup/environment"

    echo "$ROOT_DIRECTORY" > "/run/mega-setup/environment/DIRECTORY"
    echo "$MEGA_IP"        > "/run/mega-setup/environment/IP"
    echo "$MEGA_PORT"      > "/run/mega-setup/environment/PORT"
}

# -------------------------------------------------------------------------------
#       Bootstrap mitmdump services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #       Create mitmdump environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mitmdump/environment"

    echo "$MEGA_IP"    > "/run/mitmdump/environment/MEGA_IP"
    echo "$MEGA_PORT"  > "/run/mitmdump/environment/MEGA_PORT"
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    HOME="/root" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( $STARTUP_TIMEOUT * 1000 ))" \
    S6_STAGE2_HOOK="/usr/sbin/s6-stage2-hook" \
    /init
