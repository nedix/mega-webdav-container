ARG ALPINE_VERSION=3.20
ARG CRYPTOPP_VERSION=8_9_0
ARG MEGA_CMD_VERSION=1.7.0
ARG MEGA_SDK_VERSION=7.14.1
ARG MITMPROXY_VERSION=10.4.2
ARG PYTHON_VERSION=3.12

FROM alpine:${ALPINE_VERSION} AS cryptopp

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

FROM alpine:${ALPINE_VERSION} AS mega

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

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS mitmproxy

ARG MITMPROXY_VERSION

RUN apk add \
        bsd-compat-headers \
        build-base \
        curl \
        openssl-dev \
    && curl -fsSL https://sh.rustup.rs \
    | sh -s -- --profile minimal --default-toolchain stable -y \
    && source ~/.cargo/env \
    && pip install --upgrade pip \
    && pip install \
        --ignore-installed \
        mitmproxy=="$MITMPROXY_VERSION"

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
        sqlite-libs \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add \
        s6-overlay \
        skalibs-dev

COPY --link --from=mega /usr/bin/mega-cmd-server /usr/bin/
COPY --link --from=mega /usr/bin/mega-exec /usr/bin/

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# Webdav
EXPOSE 80/tcp

HEALTHCHECK CMD nc -z 127.0.0.1 80
