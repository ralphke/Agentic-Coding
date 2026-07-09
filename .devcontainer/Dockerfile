FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04
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
ARG GO_VERSION=1.26.5
ARG GO_SHA256=5c2c3b16caefa1d968a94c1daca04a7ca301a496d9b086e17ad77bb81393f053
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
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Pre-install prerequisites for devcontainer features
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
