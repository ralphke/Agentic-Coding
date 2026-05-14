# DevContainer Security & CVE Scanning Guide

## Overview

This devcontainer uses a **security-first approach** with automated CVE scanning, pinned dependencies, and hardened image optimization.

### Architecture

```
┌─────────────────────────────────────────┐
│ Development Container (Dockerfile)       │
│ • Full build toolchains                 │
│ • Package managers (apt-get)            │
│ • Docker-in-Docker support             │
│ • CVE scanning integrated              │
└─────────────────────────────────────────┘
                    ↓
         [CVE Scan Results]
         • Docker Scout
         • Trivy (optional)
                    ↓
┌─────────────────────────────────────────┐
│ Production Image (Dockerfile.prod)       │
│ • Multi-stage build                     │
│ • Distroless base (minimal attack surface)
│ • Non-root user (nonroot:nonroot)       │
│ • No shell, no package managers         │
│ • ~20MB vs 60+MB standard image         │
└─────────────────────────────────────────┘
```

## Security Features

### 1. Pinned Versions (No `latest` Tags)

All features and dependencies are pinned to specific versions in `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {
      "version": "10.0"  // Not "latest"
    },
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {
      "version": "27.0",
      "dockerDashComposeVersion": "2.27"
    }
  }
}
```

### 2. Base Image Digest Pinning

The Dockerfile uses content-addressable digests for reproducible builds:

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04@sha256:8e4b80099c59e85fe6f6959b80c24a04f53f67e29d2ef5e931c39c2ed4ff6a2c
```

This prevents `latest` tag attacks and ensures you always get the exact same image.

### 3. Minimal Package Footprint

Only essential packages are installed:

```dockerfile
RUN apt-get install -y --no-install-recommends \
    curl=7.88.1-14~ubuntu24.04.1 \
    tar=1.34+dfsg-1.2ubuntu0.1 \
    gzip=1.12-1ubuntu1 \
    ca-certificates=20240203 \
    potrace=1.16-1 \
    bubblewrap=0.8.0-2 \
    python3-pil=10.0.0-1ubuntu0.2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
```

## CVE Scanning

### Automated (CI/CD)

GitHub Actions workflow runs on every push to `.devcontainer/`:

```bash
# Manually trigger
gh workflow run security-scan.yml
```

**What it does:**
- ✅ Builds the devcontainer image
- ✅ Runs **Docker Scout** CVE scan (primary)
- ✅ Runs **Trivy** vulnerability scanner (secondary)
- ✅ Fails on HIGH/CRITICAL CVEs
- ✅ Uploads results to GitHub Security tab

**Files:**
- `.github/workflows/security-scan.yml` — GitHub Actions workflow

### Local (Before Push)

Scan locally to catch issues before pushing:

```bash
# Quick scan (Docker Scout)
bash .devcontainer/scan-cves.sh

# Full scan (Scout + Trivy)
bash .devcontainer/scan-cves.sh --full

# Trivy only
bash .devcontainer/scan-cves.sh --trivy
```

**Output:**
- Saves reports to `.devcontainer/security-reports/`
- `scout-report.json` — Docker Scout JSON output
- `trivy-report.json` — Trivy JSON output
- Summary files for human review

**Exit codes:**
- `0` — No HIGH/CRITICAL CVEs found ✅
- `1` — HIGH/CRITICAL CVEs detected ❌

## Production Image (Hardened)

For runtime deployments, use the production Dockerfile:

```bash
# Build production image
docker build -f .devcontainer/Dockerfile.prod -t agentic-workshop:prod .

# Scan production image
docker scout cves agentic-workshop:prod --format json

# Run container
docker run --rm -it agentic-workshop:prod
```

### Why Distroless?

**Standard Ubuntu 24.04 (~600MB):**
- Full shell (bash, dash, sh)
- Package managers (apt, dpkg)
- 100s of system utilities
- Large attack surface

**Distroless (~20MB):**
- ✗ No shell — prevents shell injection attacks
- ✗ No package managers — can't install malware post-deploy
- ✗ No libc — only statically-linked binaries work
- ✓ Immutable filesystem (where possible)
- ✓ Non-root user by default
- ✓ 97% smaller

## Minimizing Attack Surface

### Development Container (Dockerfile)

1. **Drop unnecessary capabilities:**
   ```dockerfile
   RUN setcap -r /usr/bin/ping 2>/dev/null || true
   ```

2. **Minimal package install:**
   ```dockerfile
   RUN apt-get install --no-install-recommends  # Only needed packages
   RUN apt-get clean && rm -rf /var/lib/apt/lists/*  # Clean cache
   ```

3. **Non-root user:**
   ```dockerfile
   USER vscode  # Already set in base image
   ```

4. **Pinned versions:**
   All package versions explicitly specified (see example above)

### Production Container (Dockerfile.prod)

1. **Multi-stage build:**
   - Stage 1: Full dev environment (build artifacts)
   - Stage 2: Distroless base (runtime only)
   - Build tools **never shipped** in production image

2. **Distroless base:**
   ```dockerfile
   FROM mcr.microsoft.com/cbl-mariner/distroless/base:2.0-nonroot
   ```

3. **Copy only what's needed:**
   ```dockerfile
   COPY --from=build-stage --chown=nonroot:nonroot \
     /build-artifacts /home/nonroot/.local/bin
   ```

4. **Non-root user enforced:**
   ```dockerfile
   USER nonroot:nonroot
   ```

## Policy & Gates

### Build Gates (CI/CD)

All changes to `.devcontainer/` **must**:
- ✅ Pass Docker Scout scan (no HIGH/CRITICAL)
- ✅ Pass Trivy scan (no HIGH/CRITICAL)
- ✅ Use pinned versions (no `latest` tags)
- ✅ Use digest-pinned base images

### Violations

If HIGH/CRITICAL CVEs are found:
1. The workflow fails ❌
2. Security tab shows vulnerabilities
3. PR cannot merge until resolved

## Updating Packages

When updating packages:

```bash
# 1. Update version in devcontainer.json or Dockerfile
# 2. Rebuild locally
docker build .devcontainer -t test-scan

# 3. Scan before committing
bash .devcontainer/scan-cves.sh

# 4. If CVEs found, either:
#    - Upgrade to newer version with patch
#    - Add CVE to allowlist (Trivy/Scout config)
#    - Evaluate risk vs. benefit

# 5. Commit + push (CI will re-scan automatically)
```

## Recommended Tools

### Local CVE Scanning

**Docker Scout (built-in to Docker Desktop):**
```bash
docker scout cves <image>
```

**Trivy (standalone):**
```bash
# Install
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan
trivy image <image> --severity CRITICAL,HIGH
```

### IDE Integration

**VS Code Docker extension:**
- Right-click image → "Scout: View vulnerabilities"

**Snyk VS Code extension:**
- Real-time CVE detection in code editors

## References

- [Docker Scout Documentation](https://docs.docker.com/scout/)
- [Trivy Scanner](https://github.com/aquasecurity/trivy)
- [NIST Container Security Best Practices](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
- [Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

