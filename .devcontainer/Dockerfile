FROM mcr.microsoft.com/devcontainers/base:ubuntu
# Base image: Microsoft devcontainers base
# The vsc-* local hash image only exists on the developer's machine and cannot be
# pulled in CI; this Dockerfile targets the public upstream image instead.

# Fix system-level vulnerabilities and resolve dpkg conflicts
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    dpkg --configure -a && \
    apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Go from the official distribution with checksum pinning.
ARG GO_VERSION=1.27.4
ARG GO_SHA256=7226736c2339719cda28fbf3a54d71aa63bcefe376e98cef00034268dab24840
ARG PEBBLE_VERSION=1.33.2
ARG PEBBLE_SHA256=41fbb1268e1a1640fc117db87bdcf0ae5a717d20c445b6c9228c2fb557f3f315
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz" && \
    curl -fsSL --retry 3 "https://go.dev/dl/${GO_TARBALL}" -o "/tmp/${GO_TARBALL}" && \
    echo "${GO_SHA256}  /tmp/${GO_TARBALL}" | sha256sum -c - && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf "/tmp/${GO_TARBALL}" && \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
    command -v go && \
    go version && \
    rm -f "/tmp/${GO_TARBALL}" && \
    PEBBLE_TARBALL="pebble-v${PEBBLE_VERSION}.tar.gz" && \
    curl -fsSL --retry 3 "https://github.com/canonical/pebble/archive/refs/tags/v${PEBBLE_VERSION}.tar.gz" -o "/tmp/${PEBBLE_TARBALL}" && \
    echo "${PEBBLE_SHA256}  /tmp/${PEBBLE_TARBALL}" | sha256sum -c - && \
    mkdir -p /tmp/pebble-src && \
    tar -C /tmp/pebble-src -xzf "/tmp/${PEBBLE_TARBALL}" --strip-components=1 && \
    cd /tmp/pebble-src && \
    GOTOOLCHAIN=local /usr/local/go/bin/go build -trimpath -o /usr/bin/pebble ./cmd/pebble && \
    PEBBLE_BUILD_INFO="$(GOTOOLCHAIN=local /usr/local/go/bin/go version -m /usr/bin/pebble)" && \
    printf '%s\n' "$PEBBLE_BUILD_INFO" && \
    printf '%s\n' "$PEBBLE_BUILD_INFO" | grep -Fx '/usr/bin/pebble: go1.27.4' >/dev/null && \
    rm -rf /tmp/pebble-src "/tmp/${PEBBLE_TARBALL}" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Pre-install prerequisites for devcontainer features
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
