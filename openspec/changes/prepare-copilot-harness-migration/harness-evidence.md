# Copilot Harness Evidence

## Discovery verification

The active Copilot harness session successfully discovered:

- 11 custom agents from `.github/agents/*.agent.md`
- 2 instruction files from `.github/instructions/*.instructions.md`
- 30 canonical skill entry points from `.github/skills/*/SKILL.md`
- 12 OpenSpec operational skills from `.github/skills/openspec-*/SKILL.md`
- GitHub, OpenSpec filesystem, and Azure MCP integrations from `.mcp.json`

All 11 agents, 2 instruction files, and 30 canonical skills contain YAML
frontmatter. The session loaded the OpenSpec apply skill from the repository.

## Prompt verification

The repository has no active `*.prompt.md` files after migration. Operational
workflows are discoverable as explicit-invocation skills. The eight numbered
`.github/prompts/0*-*.md` files remain present as educational history.

## Tool activity verification

The session used the OpenSpec CLI for change status and apply instructions,
read `openspec/` through the OpenSpec filesystem MCP tools, and retrieved pull
request data through GitHub MCP. These representative tool calls matched the
documented proposal, implementation, and review workflows.

## Workflow verification

- Proposal instructions resolved the current `proposal.md` output and its
  dependency set in the Copilot harness.
- Design instructions resolved `design.md` with the proposal dependency.
- The QA helper classified this accepted proposal as nonvisual and confirmed
  that no UX artifacts or UX tests are required while functional gates remain.
- The review workflow used GitHub MCP to read PR file diffs and review evidence,
  matching the documented changed-file and readiness checks.

## Compatibility boundary

Copilot-native agents, instructions, skills, and MCP tools passed representative
workflow checks. No active Local-harness chat participant references remain in
repository customizations. The customer-specific security MCP is retained only
as comments for a future hosted endpoint and cannot start or receive tools in
the current configuration.

No repository-owned replacement for the Upgrade extension participant was
found. The installed extension remains publisher-owned; a future plugin, MCP
server, extension tools, or documented compatibility path must be supplied and
verified by the extension publisher.

## Final validation

- `openspec validate ... --strict --json`: passed with zero issues.
- `scripts/validate-openspec-local.sh`: passed after correcting change-directory
  extraction to use `openspec/changes/<slug>` rather than files beneath it.
- `tests/devcontainer-workflow.test.sh`: passed.
- CI workshop structure, ordered prompt, JSON, shebang, and Markdown tab checks:
  passed.
- Shared manifest validation: passed.
- Customization discovery: all 43 agent, instruction, and skill frontmatter
  files parsed as valid YAML; all canonical locations and historical prompts
  were present.

## Legacy command removal

- Removed all seven legacy OpenSpec alias skill entry points.
- Renamed the legacy `.continue/prompts` files to their maintained
  `openspec-*` equivalents and updated their prompt metadata and handoffs.
- Replaced legacy command references across active workflows, managed
  customizations, OpenSpec source specs, templates, wiki content, and historical
  workshop files.
- Verified that no legacy command reference or skill path remains in the
  repository.
