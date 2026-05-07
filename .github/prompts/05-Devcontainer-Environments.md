# Prompt 05: Devcontainer + Target Environments Setup

## Source prompt

Add target environments and programming languages: Python 3.14, .NET 10, Aspire, Data API Builder (DAB). Participants use Mac, Windows 11, or GitHub Codespaces. Local development should support VS Code + Docker Desktop as devcontainers. Create a plan for this setup.

## Design decisions

- Single `.devcontainer/devcontainer.json` using devcontainer features (no custom Dockerfile) — identical environment on all three device types
- `docker-outside-of-docker` feature (not docker-in-docker) — .NET Aspire requires access to the host Docker daemon to orchestrate service sidecars; DooD mounts `/var/run/docker.sock`
- Aspire and DAB installed in `post-create.sh` (workload + global tool) rather than baked into the image
- Port 18888 auto-opens in browser (Aspire Dashboard)

## Actions performed

1. Created `.devcontainer/devcontainer.json` — features: Python 3.14, .NET 10, docker-outside-of-docker, Azure CLI; VS Code extensions: C# Dev Kit, Python, Pylance, REST Client, Docker, Copilot; port forwards: 18888, 5000, 5001, 8000, 1433
2. Created `.devcontainer/post-create.sh` — installs Aspire workload, DAB global tool, upgrades pip, prints version summary
3. Created `doc/environments.md` — runtime table, device matrix (Mac/Win11/Codespaces), devcontainer quick-start, port reference
4. Updated `doc/setup.md` — added Docker Desktop prerequisite, one-click devcontainer start steps, devcontainer verification checklist
5. Updated `.github/workflows/ci.yml` — added devcontainer files to required-file check; added devcontainer validation step (JSON parse + shebang check)
6. Updated `.github/copilot-instructions.md` — Commands section now lists actual tool commands; Architecture section references .devcontainer/; new Target runtimes section

## Files created

- .devcontainer/devcontainer.json
- .devcontainer/post-create.sh
- doc/environments.md
- .github/prompts/05-Devcontainer-Environments.md

## Files updated

- doc/setup.md
- .github/workflows/ci.yml
- .github/copilot-instructions.md
