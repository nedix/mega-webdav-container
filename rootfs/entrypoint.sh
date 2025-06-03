#!/usr/bin/env sh

: ${MEGA_DIRECTORY}
: ${MEGA_EMAIL}
: ${MEGA_PASSWORD}
: ${WEBDAV_PASSWORD_HASH}
: ${WEBDAV_USERNAME}

# -------------------------------------------------------------------------------
#       Bootstrap mega services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #       Create mega-login environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mega-login/environment"

    echo "$MEGA_EMAIL"    > "/run/mega-login/environment/MEGA_EMAIL"
    echo "$MEGA_PASSWORD" > "/run/mega-login/environment/MEGA_PASSWORD"

    # -------------------------------------------------------------------------------
    #       Create mega-setup environment
    # -------------------------------------------------------------------------------
    mkdir -p "/run/mega-setup/environment"

    echo "$MEGA_DIRECTORY" > "/run/mega-setup/environment/MEGA_DIRECTORY"
}

# -------------------------------------------------------------------------------
#       Bootstrap mitmdump service
# -------------------------------------------------------------------------------
{
    mkdir -p "/run/mitmdump/environment"

    echo "$WEBDAV_PASSWORD_HASH" > "/run/mitmdump/environment/WEBDAV_PASSWORD_HASH"
    echo "$WEBDAV_USERNAME"      > "/run/mitmdump/environment/WEBDAV_USERNAME"
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    HOME="/root" \
    S6_STAGE2_HOOK="/usr/sbin/s6-stage2-hook" \
    /init
