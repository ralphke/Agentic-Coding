# Delta for copilot-harness-migration

## ADDED Requirements

### Requirement: Copilot harness migration readiness

The repository MUST provide customizations in native Copilot locations and MUST verify representative workflows before legacy retirement.

#### Scenario: Repository customizations are discoverable

- GIVEN the repository has agents, instructions, skills, and MCP configuration
- WHEN a new Copilot harness session starts
- THEN agents are discoverable in `.github/agents`
- AND instructions are discoverable in `.github/instructions`
- AND skills are discoverable in `.github/skills/<name>/SKILL.md`
- AND MCP tools are discoverable from `.mcp.json`

#### Scenario: Duplicate skills are unambiguous

- GIVEN two skill files exist as `skill.md` and `SKILL.md` in the same directory
- WHEN their contents are identical
- THEN the lowercase duplicate MAY be removed
- AND `SKILL.md` remains the canonical discovery file

#### Scenario: Different duplicate content requires review

- GIVEN two skill files exist as `skill.md` and `SKILL.md` in the same directory
- WHEN their contents differ
- THEN neither file is removed automatically
- AND an explicit manual review identifies the canonical content

#### Scenario: Historical prompts remain explanatory

- GIVEN a numbered `.github/prompts/0*-*.md` file
- WHEN customization migration runs
- THEN the file remains in place as repository history
- AND it is not renamed or converted as an active operational prompt

#### Scenario: MCP migration preserves secrets

- GIVEN MCP configuration contains credentials or input prompts
- WHEN the configuration is prepared for Copilot
- THEN credentials are not committed to source files
- AND the target environment provides the required environment or OAuth authentication
