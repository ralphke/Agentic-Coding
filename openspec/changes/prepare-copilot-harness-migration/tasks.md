# Tasks

## 1. Establish migration baseline

- [x] 1.1 Capture git status and record unrelated uncommitted changes; verify cleanup leaves those changes untouched
- [x] 1.2 Record the current upstream manifest version `v1.2.1` and confirm latest release `v1.3.0`
- [x] 1.3 Inventory active agents, instructions, skills, operational prompts, MCP configuration, and numbered historical prompts; verify the inventory is saved in the change evidence

## 2. Synchronize agentic-shared

- [x] 2.1 Validate `.agentic-shared.yml` and preview the `v1.3.0` synchronization; verify managed, extended, protected, and repo-local paths are reported correctly
- [x] 2.2 Apply the synchronization through `.github/scripts/sync_agentic_shared.py --target-version v1.3.0` or the repository sync workflow; verify `.agentic-shared.yml` records `v1.3.0`
- [x] 2.3 Review the synchronization diff; verify upstream-managed files are not manually edited and protected repo-local files remain intact

## 3. Verify and remove duplicate skill files

- [x] 3.1 Rebuild the post-sync inventory of `skill.md` and `SKILL.md` pairs
- [x] 3.2 Compare every pair with `cmp -s`; record identical and differing results
- [x] 3.3 Remove only pairs proven identical and keep `SKILL.md` as canonical; verify no differing pair was removed
- [x] 3.4 Ask for manual review if any differing pair exists before choosing or deleting content

## 4. Normalize active customizations

- [x] 4.1 Preserve all `.github/prompts/0*-*.md` files unchanged and document that they are educational history
- [x] 4.2 Confirm operational agents, instructions, and skills use native `.github` or Copilot paths; verify frontmatter and applyTo patterns
- [x] 4.3 Replace Local-only tool identifiers and chat-participant assumptions with harness-neutral capability descriptions or verified Copilot tool names
- [x] 4.4 Convert applicable operational prompts to skills and preserve explicit invocation with `disable-model-invocation: true` where required
- [x] 4.5 Keep repo-local additions under protected `local/` paths or manifest local declarations; verify managed files remain upstream-owned

## 5. Migrate MCP configuration

- [x] 5.1 Replace VS Code-specific MCP paths and input prompts with portable `.mcp.json` entries, environment references, or OAuth; verify no secrets are written
- [x] 5.2 Restrict MCP tools to the capabilities required for the OpenSpec workflow; verify wildcard access is removed or justified
- [x] 5.3 Test MCP startup and tool calls in a new Copilot harness session; verify authentication in the target environment

## 6. Verify Copilot harness behavior

- [x] 6.1 Start a disposable Copilot harness session and verify agent, instruction, skill, prompt, and MCP discovery
- [x] 6.2 Run representative proposal, design, test, and review workflows; verify tool activity matches the documented workflow
- [x] 6.3 Verify Local-only compatibility behavior and preserve fallback until Copilot replacements pass
- [x] 6.4 Verify the Upgrade extension participant has no repository-side replacement and document publisher follow-up if required

## 7. Retire legacy copies and document migration

- [x] 7.1 Remove legacy Local-only copies and settings only after verification passes
- [x] 7.2 Update repository documentation to describe `v1.3.0`, portable paths, and the distinction between historical and operational prompts
- [x] 7.3 Run OpenSpec validation, repository CI checks, and customization discovery validation; verify all migration checks pass
- [x] 7.4 Remove legacy OpenSpec alias skills and migrate all repository references, including historical files, to maintained `openspec-*` commands

## Workflow follow-up

- After implementation tasks pass, run the normal OpenSpec verify workflow.
- Archive this change only after quality gates and human/repository review are satisfied.
