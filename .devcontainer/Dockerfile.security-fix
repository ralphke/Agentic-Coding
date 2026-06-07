FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04
# Base image matches devcontainer.json "image" field.
# The vsc-* local hash image only exists on the developer's machine and cannot be
# pulled in CI; this Dockerfile targets the public upstream image instead.
# Fix system-level vulnerabilities
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --only-upgrade linux-image-generic && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Go from the official distribution with checksum pinning.
ARG GO_VERSION=1.26.4
ARG GO_SHA256=1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f
RUN apt-get update && \
        apt-get install -y --no-install-recommends ca-certificates curl && \
        GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz" && \
        curl -fsSL "https://go.dev/dl/${GO_TARBALL}" -o "/tmp/${GO_TARBALL}" && \
        echo "${GO_SHA256}  /tmp/${GO_TARBALL}" | sha256sum -c - && \
        rm -rf /usr/local/go && \
        tar -C /usr/local -xzf "/tmp/${GO_TARBALL}" && \
        ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
        command -v go && \
        go version && \
        rm -f "/tmp/${GO_TARBALL}" && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

USER root
