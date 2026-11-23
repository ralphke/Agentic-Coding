# Proposal

## Why

The repository still pins `agentic-shared` at `v1.2.1` and contains mixed agent customization formats, duplicate skill files, and VS Code-only workflow assumptions. VS Code Copilot now separates Local and Copilot harnesses, with the Local harness deprecated and chat participants unsupported in the Copilot harness. The repository needs a verified migration plan before the harness transition and should consume the latest upstream shared assets.

## What Changes

- Synchronize repository-owned managed assets to the latest `ralphke/agentic-shared` release, `v1.3.0`.
- Preserve repo-local customizations under their protected `local/` paths.
- Normalize agent, instruction, prompt, skill, MCP, and documentation locations for Copilot harness discovery.
- Compare duplicate `skill.md` and `SKILL.md` pairs byte-for-byte; remove only confirmed identical lowercase duplicates.
- Preserve the numbered `0*-*.md` prompt files as chronological educational history, not as active operational prompts.
- Replace Local-harness-specific tool references and chat-participant dependencies where a portable equivalent exists.
- Remove legacy OpenSpec skill aliases and migrate every command, prompt, active
  workflow, and historical reference to maintained `openspec-*` entry points.
- Keep the Upgrade extension participant out of scope for implementation because its replacement is owned by the extension publisher.
- Verify representative workflows in a Copilot harness session before removing legacy copies or compatibility settings.

## Capabilities

### New Capabilities

- `copilot-harness-migration`: Repository customization discovery and verification compatible with the Copilot harness.

### Modified Capabilities

- `sdlc-process`: Managed Software Fabric assets and consumer-project workflows must support the Copilot harness without relying on Local-only APIs.

## Impact

Affected areas include `.agentic-shared.yml`, `.github/agents`, `.github/skills`, `.github/prompts`, `.github/instructions`, `.github/workflows`, `.mcp.json`, VS Code settings, and migration documentation. The implementation may remove confirmed duplicate files and update upstream-managed assets only through the agentic-shared synchronization workflow.

## UX Applicability

```json
{
  "required": false,
  "reason": "The scoped work changes repository harness configuration, agent and skill assets, MCP configuration, and migration documentation; it does not change a user-facing visual interface."
}
```
