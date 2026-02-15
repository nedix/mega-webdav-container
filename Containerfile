ARG ALPINE_VERSION=3.23
ARG CRYPTOPP_VERSION=8_9_0
ARG MEGA_CMD_VERSION=1.7.0
ARG MITMPROXY_VERSION=12.2.1
ARG PYTHON_VERSION=3.13
ARG S6_OVERLAY_VERSION=3.2.2.0

FROM alpine:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64) \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
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
        git \
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

RUN git clone --depth 1 --recursive https://github.com/meganz/MEGAcmd.git . \
    && git fetch origin tag "${MEGA_CMD_VERSION}_Linux" \
    && git checkout "tags/${MEGA_CMD_VERSION}_Linux" \
    && git submodule update --depth 1 --recursive \
    && sed -i 's|/bin/bash|/bin/sh|' ./src/client/mega-* \
    && sed -E \
        -e 's|MAX_BUFFER_SIZE = .*;|MAX_BUFFER_SIZE = 33554432;|' \
        -e 's|MAX_OUTPUT_SIZE = .*;|MAX_OUTPUT_SIZE = 16384;|' \
        -i ./sdk/include/megaapi_impl.h \
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

ARG MITMPROXY_VERSION

RUN case "$(uname -m)" in \
        aarch64) \
            RUST_TOOLCHAIN="nightly-aarch64-unknown-linux-musl" \
        ;; arm*) \
            RUST_TOOLCHAIN="nightly-arm-unknown-linux-musleabi" \
        ;; x86_64) \
            RUST_TOOLCHAIN="nightly-x86_64-unknown-linux-musl" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && apk add \
        bsd-compat-headers \
        build-base \
        llvm \
        openssl-dev \
    && wget -qO- https://sh.rustup.rs \
    | sh -s -- --profile minimal --default-toolchain "$RUST_TOOLCHAIN" --component rust-src -y \
    && . ~/.cargo/env \
    && cargo install \
        --locked \
        bpf-linker \
    && ln -s /build/mitmdump/ /opt/ \
    && python -m venv --copies /opt/mitmdump/venv \
    && . /opt/mitmdump/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install \
        --ignore-installed \
        mitmproxy=="$MITMPROXY_VERSION"

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

ENTRYPOINT ["/entrypoint.sh"]

# Webdav
EXPOSE 80/tcp

HEALTHCHECK CMD nc -z 127.0.0.1 80
