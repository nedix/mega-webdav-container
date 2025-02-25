ARG ALPINE_VERSION=3.21
ARG CRYPTOPP_VERSION=8_9_0
ARG MEGA_CMD_VERSION=1.7.0
ARG MEGA_SDK_VERSION=8.6.0
ARG MITMDUMP_VERSION=10.4.2
ARG PYTHON_VERSION=3.12
ARG S6_OVERLAY_VERSION=3.2.0.0
ARG STARTUP_TIMEOUT=120

FROM alpine:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64|arm*) \
            CPU_ARCHITECTURE="aarch64" \
        ;; x86_64) \
            CPU_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${CPU_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

FROM base AS cryptopp

RUN apk add \
        curl \
        g++

WORKDIR /build/cryptopp/

ARG CRYPTOPP_VERSION

RUN curl -fsSL "https://github.com/weidai11/cryptopp/archive/refs/tags/CRYPTOPP_${CRYPTOPP_VERSION}/cryptopp${CRYPTOPP_VERSION//_/}.tar.gz" \
    | tar -xz --strip-components=1 \
    && g++ -DNDEBUG -g3 -O3 -march=native -pipe -c cryptlib.cpp \
    ; ar rcs libcryptopp.a *.o \
    && mv libcryptopp.a /usr/local/lib/

FROM base AS mega

COPY --link --from=cryptopp /usr/local/lib/libcryptopp.a /usr/local/lib/

RUN apk add \
        autoconf \
        automake \
        c-ares-dev \
        crypto++-dev \
        curl \
        curl-dev \
        freeimage-dev \
        g++ \
        icu-dev \
        libsodium-dev \
        libtool \
        libuv-dev \
        linux-headers \
        make \
        openssl-dev \
        readline-dev \
        sqlite-dev \
        zlib-dev \
        zlib-static

WORKDIR /build/mega/

ARG MEGA_CMD_VERSION
ARG MEGA_SDK_VERSION

RUN curl -fsSL "https://github.com/meganz/MEGAcmd/archive/refs/tags/${MEGA_CMD_VERSION}_Linux/MEGAcmd-${MEGA_CMD_VERSION}.tar.gz" \
    | tar -xz --strip-components=1 \
    && curl -fsSL "https://github.com/meganz/sdk/archive/refs/tags/v${MEGA_SDK_VERSION}/sdk-v${MEGA_SDK_VERSION}.tar.gz" \
    | tar -xzC ./sdk --strip-components=1 \
    && sed -i 's|/bin/bash|/bin/sh|' ./src/client/mega-* \
    && sed -i \
        -e 's|MAX_BUFFER_SIZE = .*;|MAX_BUFFER_SIZE = 33554432;|' \
        -e 's|MAX_OUTPUT_SIZE = .*;|MAX_OUTPUT_SIZE = 16384;|' \
        ./sdk/include/megaapi_impl.h \
    && ./autogen.sh \
    && ./configure \
        CXXFLAGS="-O3 -flto=auto -fpermissive" \
        --build=$CBUILD \
        --host=$CHOST \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-examples \
        --disable-shared \
    && make -j$(( $(nproc) + 1 )) \
    && make install

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS mitmdump

WORKDIR /build/mitmdump/

ARG MITMDUMP_VERSION

RUN apk add \
        bsd-compat-headers \
        build-base \
        openssl-dev \
    && wget -qO- https://sh.rustup.rs \
    | sh -s -- --profile minimal --default-toolchain stable -y \
    && . ~/.cargo/env \
    && ln -s /build/mitmdump/ /opt/ \
    && python -m venv --copies /opt/mitmdump/venv \
    && . /opt/mitmdump/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install \
        --ignore-installed \
        mitmproxy=="$MITMDUMP_VERSION"

FROM base

RUN apk add \
    	icu-libs \
        c-ares \
        crypto++ \
        freeimage \
        fuse3 \
        iproute2 \
        iptables \
        libcurl \
        libgcc \
        libsodium \
        libstdc++ \
        libtool \
        libuv \
        nftables \
        python3 \
        sqlite-libs

COPY /rootfs/ /

COPY --link --from=mega /usr/bin/mega-cmd-server /usr/local/bin/
COPY --link --from=mega /usr/bin/mega-exec /usr/local/bin/
COPY --link --from=mitmdump /build/mitmdump/venv/ /opt/mitmdump/venv/

ARG STARTUP_TIMEOUT
ENV STARTUP_TIMEOUT="$STARTUP_TIMEOUT"

ENTRYPOINT ["/entrypoint.sh"]

# Webdav
EXPOSE 80/tcp

HEALTHCHECK CMD nc -z 127.0.0.1 80
