# Migration Baseline

## Repository state

Existing unrelated modifications at baseline:

- `.devcontainer/devcontainer-lock.json`
- `.mcp.json`
- `.vscode/settings.json`

These files are preserved and not reset or normalized without a separate task and verification.

## Upstream target

- Manifest version: `v1.2.1`
- Latest `ralphke/agentic-shared` release: `v1.3.0`
- Release date: `2026-11-06`
- Release URL: <https://github.com/ralphke/agentic-shared/releases/tag/v1.3.0>

## Customization inventory

- Agents: 10 files under `.github/agents`
- Instructions: 2 files under `.github/instructions`
- Skills: canonical and duplicate skill files under `.github/skills`
- MCP: `.mcp.json`
- Historical prompts: 8 numbered files under `.github/prompts/0*-*.md`

## Historical prompts

- `01-Initial-Prompt.md`
- `02-Workshop-Scaffold-Implementation.md`
- `03-Spec-Based-Agentic-Development.md`
- `04-VSCode-Agents-App-Prerequisite.md`
- `05-Devcontainer-Environments.md`
- `06-OpenSPEC-Autonomous-SDLC.md`
- `07-ArchitectureDiagram.md`
- `08-Agent-Skill-CoWork-Diagram.md`

These files are chronological educational history and must remain unchanged.

## Duplicate skill baseline

The following `skill.md` / `SKILL.md` pairs are byte-identical:

- `deploy-pipeline`
- `idea-to-spec`
- `legal-compliance-review`
- `pr-review`
- `security-review`
- `spec-to-design`
- `test-generation`
- `workflow-retrospective`
