# Design

## Context

See proposal.md for motivation. The repository consumes shared assets from `ralphke/agentic-shared` and uses repo-local assets for extensions. The manifest currently pins `v1.2.1`; the latest published release is `v1.3.0`. Existing customization files are partially in native Copilot locations, but they include duplicate skill definitions, Local-oriented tool assumptions, a VS Code-specific MCP path, and educational prompt history that must not be treated as active prompts.

## Goals / Non-Goals

**Goals:**

- Synchronize upstream assets without overwriting protected repo-local files.
- Establish a single canonical skill file for every duplicate skill pair.
- Preserve portable workflow behavior across Copilot and Local compatibility sessions.
- Verify MCP, agents, instructions, skills, and representative workflows before legacy retirement.

**Non-Goals:**

- Reimplement the Upgrade extension participant inside this repository.
- Modify external extension packages or patch installed Marketplace releases.
- Delete numbered historical prompt files because they educate users about the repository's origin.
- Archive this change or alter unrelated uncommitted files.

## Decisions

### 1. Synchronize upstream first

Update `.agentic-shared.yml` to `v1.3.0` and synchronize assets using `.github/scripts/sync_agentic_shared.py` or the repository-owned sync workflow. Managed assets remain upstream-owned; repo-local additions stay under protected `local/` paths.

Alternatives considered:

- Clean local assets first, then sync: rejected because upstream changes could reintroduce duplicates or overwrite cleanup decisions.
- Fork upstream assets into this repository: rejected because the manifest already provides a supported synchronization boundary.

### 2. Use byte comparison as the duplicate removal gate

For each pair of `skill.md` and `SKILL.md`, run `cmp -s`. Remove `skill.md` only when the pair is identical. If a pair differs, preserve both and flag it for manual ownership and canonical-content review.

Alternatives considered:

- Keep both files: rejected for identical pairs because duplicate discovery creates ambiguity.
- Keep the lowercase file: rejected because `SKILL.md` is the canonical workspace convention.

### 3. Separate active prompts from historical prompts

Operational prompt wrappers should be considered for skill migration. Files matching `0*-*.md` under `.github/prompts` remain documentation and explanatory history. They must not be renamed or converted during the customization cleanup.

### 4. Normalize portable customizations after upstream sync

Inventory native locations and replace Local-only tool identifiers with the capabilities available in the Copilot harness. MCP configuration moves to portable `.mcp.json`, with workspace-relative paths and environment-based authentication. No migration should remove a source until a representative task succeeds in Copilot.

### 5. Keep extension replacement publisher-owned

The Upgrade extension chat participant cannot be converted automatically in this repository. This change may document the gap and preserve compatibility use, but only the extension publisher can supply a plugin, MCP server/tools, or extension tools.

## Risks / Trade-offs

- `v1.3.0` may introduce breaking customization formats → Run sync preview and review the generated diff before applying.
- Identical duplicate files may have case-insensitive filesystem implications → Verify byte equality and use repository-relative canonical paths.
- Copilot may not expose all Local tool names → Map capabilities, not names, and test actual tool activity.
- MCP authentication or paths may differ in remote/container sessions → Test in the target environment and keep secrets out of source files.
- User customization state may remain outside the repository → Document profile-level migration separately and verify discovery.

## Migration Plan

1. Capture repository status and preserve unrelated uncommitted changes.
2. Record the current and target upstream versions.
3. Preview the `v1.3.0` synchronization and review managed/local asset boundaries.
4. Apply the synchronization through the supported repository mechanism.
5. Rebuild the duplicate and customization inventories from the post-sync state.
6. Compare duplicate skill files and remove only byte-identical lowercase copies.
7. Normalize agent tools, MCP configuration, and operational prompts.
8. Retain numbered prompt history unchanged.
9. Validate in Copilot and Local compatibility sessions.
10. Remove legacy files/settings only after equivalent behavior passes.

Rollback uses the sync preview or the previously pinned manifest/tag, plus the git diff for repo-local edits. No unrelated work should be reset.
