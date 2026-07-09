# Devcontainer Configuration Refactor

## File Structure (DRY approach)

```
.devcontainer/
├── devcontainer-base.json         ← Shared config (all features, extensions, ports)
├── devcontainer.json              ← Active config (extends base + build mode)
├── devcontainer-prebuilt.json     ← Template (extends base + image mode)
├── devcontainer.local.json        ← Developer overrides (machine-local, extends active config)
├── Dockerfile                     ← Base image + tools
├── devcontainer-workflow.sh       ← Mode switching automation
└── features/workshop-tools/       ← Custom feature (separate, required by spec)
```

## Configuration Hierarchy

### Active Build Mode
```json
devcontainer.json extends devcontainer-base.json
  - Inherits: features, extensions, forwarded ports, workspace settings
  - Adds: build mode (builds from Dockerfile)
  - Name: "Agentic Coding Workshop"
```

### Pre-built Mode (Template)
```json
devcontainer-prebuilt.json extends devcontainer-base.json
  - Inherits: features, extensions, forwarded ports, workspace settings
  - Adds: image mode (pulls from GHCR)
  - Name: "Agentic Coding Workshop (Pre-built)"
```

### Local Developer Overrides (Optional)
```json
devcontainer.local.json extends devcontainer.json (or devcontainer-prebuilt.json)
  - Machine-specific mounts, environment variables
  - NOT committed to git (add to .gitignore)
  - Example: custom workspace data paths
```

## Why This Structure

| Aspect | Before | After | Benefit |
|--------|--------|-------|---------|
| Duplication | 2 identical full configs | 1 shared base + 2 thin configs | 95% less duplication |
| Maintenance | Update both files | Update base.json once | Single source of truth |
| Switching | Copy full file | Copy thin file | Faster, clearer intent |
| Git conflicts | Team edits duplicate features | Single base.json | Fewer merge conflicts |
| Local overrides | Ignore in .gitignore | Proper extends pattern | Cleaner separation |

## Usage

### Initial Setup (Build Locally)
```bash
# devcontainer.json already points to build mode
cd .devcontainer
# In VS Code: Cmd+Shift+P > Dev Containers: Rebuild Container
```

### Build and Push to GHCR
```bash
docker login ghcr.io
./devcontainer-workflow.sh build-and-push latest
```

### Switch to Pre-built Mode
```bash
./devcontainer-workflow.sh use-prebuilt
# In VS Code: Cmd+Shift+P > Dev Containers: Rebuild Container
```

### Add Local Developer Overrides
Create `.devcontainer/devcontainer.local.json`:
```json
{
  "extends": "./devcontainer.json",
  "mounts": [
    "source=${localEnv:MY_LOCAL_DATA},target=/workspace-data,type=bind"
  ],
  "remoteEnv": {
    "MY_VAR": "my_value"
  }
}
```

Then: `devcontainer.json` → `.devcontainer/devcontainer.local.json` (set as active in VS Code)

## Key Points

- **Base config** (`devcontainer-base.json`): Never commit config-switching changes here
- **Active config** (`devcontainer.json`): Safe to commit, defines build mode
- **Template** (`devcontainer-prebuilt.json`): Safe to commit, not normally active
- **Local config** (`devcontainer.local.json`): Add to `.gitignore`, never commit
- **Workflow script** (`devcontainer-workflow.sh`): Automates safe mode switching
