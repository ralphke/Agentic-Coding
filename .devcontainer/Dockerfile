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
ARG GO_VERSION=1.26.5
ARG GO_SHA256=5c2c3b16caefa1d968a94c1daca04a7ca301a496d9b086e17ad77bb81393f053
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

RUN curl -fsSL https://dhi.io/keyring/dhi-deb-gpg.D46852F6925E9F71.key | gpg --dearmor -o /usr/share/keyrings/dhi-deb-main.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/dhi-deb-main.gpg] http://dhi.io/deb/debian/main trixie main" > /etc/apt/sources.list.d/dhi.list && \
    curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh -s --

USER root
