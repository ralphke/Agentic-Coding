# Workshop Setup: VS Code Agents Application

All workshop participants need the **VS Code Agents application** installed and configured before the first lab. This is the primary IDE for the workshop — it provides the agent-first environment where you interact with GitHub Copilot through chat while the agent plans, implements, and verifies changes autonomously.

## What is the Agents application?

The [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) is a separate app installed alongside VS Code Insiders, purpose-built for the agent-first workflow:

- **One place for all projects** — manage sessions across all your workspaces without switching windows
- **Parallel sessions** — run multiple agent sessions simultaneously across different projects
- **Chat as the primary interface** — describe what you want, the agent plans and implements; you review
- **Changes panel** — inspect, diff, and accept agent edits before committing

> **Code-first vs. agent-first:** In a standard VS Code window you write code and use AI as an assistant. In the Agents app you define the problem in chat and the agent does the implementation. This workshop is built for the agent-first model.

## Step 1 — Install VS Code Insiders

Download and install **[VS Code Insiders](https://code.visualstudio.com/insiders/)**.

The Agents application is bundled with VS Code Insiders — no separate download is needed.

## Step 2 — Open the Agents application

- **Windows / macOS:** Launch **Visual Studio Code Agents - Insiders** from your Start menu or Applications folder.
- **Command line:** `code-insiders --agents`
- **From VS Code Insiders:** select the Agents icon in the title bar, or run `Chat: Open Agents Application` from the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`).

## Step 3 — Sign in and activate GitHub Copilot

1. The Agents app will prompt for GitHub authentication on first launch. Sign in with your GitHub account.
2. If you don't have a Copilot subscription, follow [Set up GitHub Copilot in VS Code](https://code.visualstudio.com/docs/copilot/setup) to activate one.
3. Verify Copilot is active: start a new session (`Ctrl+N` / `Cmd+N`), select a workspace folder, and type a test prompt.

## Step 4 — Trust your workshop folder

Open the `Agentic-Coding` repository folder in the Agents app:

1. Select **New** in the sidebar.
2. Choose the local folder where you cloned this repository.
3. If prompted, click **Trust Folder**.

You are ready for the first lab.

## Verification checklist

- [ ] VS Code Insiders is installed
- [ ] VS Code Agents application opens without errors
- [ ] You are signed in with a GitHub account that has Copilot access
- [ ] You can start a new session in the workshop folder
- [ ] A test prompt produces a response from the agent

## Reference

- [VS Code Agents application docs](https://code.visualstudio.com/docs/copilot/agents-app)
- [Set up GitHub Copilot in VS Code](https://code.visualstudio.com/docs/copilot/setup)
- [VS Code Insiders download](https://code.visualstudio.com/insiders/)
- [Workshop environments and devcontainer guide](environments.md)

---

## Devcontainer setup (Mac, Windows 11, Codespaces)

The workshop provides a ready-made devcontainer with **Python 3.14**, **.NET 10**, **Aspire**, and **Data API Builder** pre-installed. This is the recommended path for all coding exercises.

See **[doc/environments.md](environments.md)** for the full device matrix, quick-start steps, and port reference.

### Extra prerequisite for Mac and Windows 11

Install and start **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** before opening the repository in VS Code. Codespaces users do not need Docker Desktop.

### One-click start

1. Open the repository folder in **VS Code Insiders**.
2. Click **"Reopen in Container"** when prompted (or run `Dev Containers: Reopen in Container` from the Command Palette).
3. Wait for the container to build and the post-create script to finish (~3 min on first run).
4. Verify in a terminal:

   ```bash
   python3 --version   # 3.14.x
   dotnet --version    # 10.0.x
   dab --version       # Data API Builder x.x.x
   ```

### Verification checklist (devcontainer)

- [ ] Docker Desktop is installed and running (Mac / Windows 11)
- [ ] Devcontainer builds without errors
- [ ] `python3 --version` shows 3.14.x
- [ ] `dotnet --version` shows 10.0.x
- [ ] `dab --version` shows a version number
- [ ] `docker version` shows the host Docker version

