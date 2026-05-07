# Workshop Environments

This document describes the target runtimes, participant device matrix, and how to get a fully configured development environment running on any supported device.

---

## Target runtimes

| Runtime | Version | Purpose |
|---------|---------|---------|
| Python | 3.14 (latest) | Scripting exercises, data exercises, agentic tooling |
| .NET | 10.0 (latest) | Web API and service exercises |
| .NET Aspire | bundled with .NET 10 workload | Multi-service orchestration and dashboard |
| Data API Builder (DAB) | latest | REST/GraphQL API generation from database schemas |
| Docker | host Docker Desktop | Container runtime for Aspire sidecars and DAB |

### About the tools

**Python 3.14** — latest stable release. Used for scripting-style exercises and agentic automation examples.

**[.NET 10](https://dotnet.microsoft.com/download/dotnet/10.0)** — latest LTS-track release. Used for ASP.NET Web API exercises and Aspire orchestration.

**[.NET Aspire](https://learn.microsoft.com/dotnet/aspire/get-started/aspire-overview)** — a .NET workload for building cloud-native, observable, production-ready distributed applications. Provides a developer dashboard, service discovery, and container orchestration for local development.

**[Data API Builder (DAB)](https://learn.microsoft.com/azure/data-api-builder/overview)** — turns a database schema into a REST and GraphQL API with zero hand-written boilerplate. Install: `dotnet tool install --global microsoft.dataapibuilder`.

---

## Participant device matrix

| Device | Path | Docker | Devcontainer support |
|--------|------|--------|----------------------|
| macOS (Apple Silicon or Intel) | Local + devcontainer | [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) | ✅ via VS Code Insiders |
| Windows 11 | Local + devcontainer | [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) (WSL2 backend) | ✅ via VS Code Insiders |
| GitHub Codespaces | Browser or VS Code | Built-in (no install) | ✅ automatic |

All three paths use the same `.devcontainer/devcontainer.json` — you get identical tool versions regardless of device.

---

## Quick start: devcontainer (recommended for Mac and Windows 11)

### Prerequisites

- [VS Code Insiders](https://code.visualstudio.com/insiders/) installed
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and **running**
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed in VS Code Insiders
- This repository cloned locally

### Steps

1. Open VS Code Insiders and open the cloned repository folder.
2. When prompted **"Reopen in Container"**, click it. If the prompt doesn't appear, run `Dev Containers: Reopen in Container` from the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`).
3. VS Code builds the container (first run takes a few minutes — subsequent opens are instant).
4. The post-create script runs automatically:
   - Installs `.NET Aspire` workload
   - Installs `dab` (Data API Builder) globally
   - Prints a version summary in the terminal
5. Open a new terminal and verify:

   ```bash
   python3 --version    # Python 3.14.x
   dotnet --version     # 10.0.x
   dab --version        # Data API Builder x.x.x
   docker version       # host Docker via socket
   ```

### Aspire dashboard

When you run an Aspire application, the dashboard starts on port **18888**. VS Code automatically forwards this port and opens it in your browser. If it does not open automatically, navigate to `http://localhost:18888`.

---

## Quick start: GitHub Codespaces

1. On the repository page, click **Code → Codespaces → Create codespace on main**.
2. Codespaces reads `.devcontainer/devcontainer.json` and builds the environment automatically.
3. The post-create script runs after the container is ready.
4. Open a terminal and run the same verification commands above.

> **Port forwarding in Codespaces:** The Aspire dashboard (18888) is forwarded automatically. Access it from the **Ports** tab in the VS Code web interface or the notification that appears in the terminal.

---

## What's in the devcontainer

| Component | How it's installed |
|-----------|--------------------|
| Python 3.14 | devcontainer feature `ghcr.io/devcontainers/features/python:1` |
| .NET 10 SDK | devcontainer feature `ghcr.io/devcontainers/features/dotnet:2` |
| Docker CLI (host socket) | devcontainer feature `ghcr.io/devcontainers/features/docker-outside-of-docker:1` |
| Azure CLI | devcontainer feature `ghcr.io/devcontainers/features/azure-cli:1` |
| .NET Aspire workload | `post-create.sh` → `dotnet workload install aspire` |
| Data API Builder | `post-create.sh` → `dotnet tool install -g microsoft.dataapibuilder` |
| VS Code extensions | C# Dev Kit, Python, Pylance, REST Client, Docker, GitHub Copilot |

### Why docker-outside-of-docker?

.NET Aspire orchestrates service sidecars (database, cache, message broker) as Docker containers. It needs access to the **host** Docker daemon to create and manage those containers. The `docker-outside-of-docker` feature mounts the host Docker socket (`/var/run/docker.sock`) inside the devcontainer — this works on Docker Desktop for Mac, Windows 11 (WSL2 backend), and Codespaces without any extra configuration.

---

## Port reference

| Port | Service | Notes |
|------|---------|-------|
| 18888 | Aspire Dashboard | Auto-opened in browser |
| 5000 | ASP.NET HTTP | Default Kestrel port |
| 5001 | ASP.NET HTTPS | Default Kestrel TLS port |
| 8000 | Python dev server | `python3 -m http.server 8000` |
| 1433 | SQL Server / DAB target | Used when running a local SQL container for DAB exercises |

---

## Reference

- [Dev Containers documentation](https://containers.dev)
- [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [.NET 10 downloads](https://dotnet.microsoft.com/download/dotnet/10.0)
- [.NET Aspire overview](https://learn.microsoft.com/dotnet/aspire/get-started/aspire-overview)
- [Data API Builder docs](https://learn.microsoft.com/azure/data-api-builder/overview)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
