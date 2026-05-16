# Spec 01: Ensure Agent Skills Follow Standards

This spec is intentionally limited to planning. Implementation starts only after @ralphke reviews and approves this document.

---

## Proposal

The repository contains skill definitions and agent/persona guidance under `.github/skills/` and `.github/agents/`. These artifacts need to be aligned with the Agent Skills specification, Agent Skills best practices, and optimization guidance, while remaining consistent with patterns used by Awesome Copilot. This change defines a review-first, measurable plan that updates skill quality without expanding scope outside `.github` and workspace `spec/`, `scripts/`, and `test/` folders.

---

## Requirements / Scenarios

```
Scenario: Review-first workflow is enforced
  Given the issue requests spec review before execution
  When this work starts
  Then a numbered spec exists in `spec/` and no skill implementation changes start before review

Scenario: Skills are brought to standards
  Given skill files in `.github/skills/` and related agent guidance in `.github/agents/`
  When standards alignment work is performed
  Then each skill follows agentskills.io specification and best-practice structure

Scenario: Optimization improvements are measurable
  Given baseline and post-change evaluation prompts for each updated skill
  When evaluation scripts are executed
  Then summary results show measurable prompt-quality improvement and target at least 5% relative gain

Scenario: Unapproved scope is rejected (unhappy path)
  Given a change request outside allowed folders or language/shell constraints
  When implementation planning is reviewed
  Then the request is deferred or rejected until it fits the defined scope and constraints
```

| # | Scenario | Given | When | Then |
|---|----------|-------|------|------|
| 1 | Review-first workflow is enforced | Spec review is required before execution | Work starts | Numbered spec exists and execution waits for review |
| 2 | Skills are brought to standards | Skill files exist in `.github` | Standards pass is applied | Skills align to agentskills.io + Awesome Copilot |
| 3 | Optimization improvements are measurable | Baseline and post-change evaluations are defined | Scripts run | Summary shows measurable quality gain (target ≥5%) |
| 4 | Unapproved scope is rejected | Request violates scope/constraints | Plan is reviewed | Work is deferred until compliant |

---

## Design

- **Function / API signature:** N/A (documentation and skill-definition governance change)
- **Inputs and types:**
  - Markdown skill files in `.github/skills/`
  - Related persona guidance in `.github/agents/`
  - External references: `https://agentskills.io/specification`, best-practice and optimization docs, and `https://github.com/github/awesome-copilot`
- **Outputs and types:**
  - Updated skill markdown files
  - Reusable evaluation scripts in `scripts/` (copilot cli, Python 3.14, PowerShell 7, dotnet 10, bash in that priority)
  - Evaluation tests in `test/` and a before/after summary artifact
- **Error handling:**
  - Fail evaluation when baseline is missing, metrics are non-comparable, or improvement is below agreed target
  - Fail if scripts/tests are added outside `scripts/` and `test/`
- **Dependencies / libraries:**
  - Prefer built-in CLI and standard tooling already present in the repo/devcontainer
  - Any new dependency must be justified and security-scanned before use
- **Constraints** (performance, security, backwards-compatibility):
  - Scope limited to `.github/**`, `spec/**`, `scripts/**`, `test/**`
  - Follow issue language/shell constraints and avoid adding unsupported stacks
  - Keep CI-compatible markdown and file-structure conventions intact

---

## Tasks

1. [ ] Confirm this spec with @ralphke before implementation begins.
2. [ ] Define a standards checklist mapped to agentskills.io specification and best-practice sections for each target skill.
3. [ ] Capture per-skill baseline quality metrics using evaluation prompts without skill assistance.
4. [ ] Update skill files in `.github/skills/` (and only necessary related agent guidance) to align with the standards checklist.
5. [ ] Add reusable evaluation scripts to `scripts/` using allowed tooling priority.
6. [ ] Add evaluation tests to `test/` and generate before/after summary results.
7. [ ] Validate measurable quality improvements and confirm at least 5% relative improvement where applicable.
8. [ ] Re-run repo validation checks and publish completion evidence against acceptance criteria.

---

## Out of scope

- Implementing unrelated product features outside skill/agent guidance quality.
- Adding unsupported languages, shells, or tooling not requested by the issue.
- Changes outside `.github`, `spec`, `scripts`, and `test` unless explicitly approved.

---

## Acceptance criteria

- [ ] All targeted skills follow best practices from https://agentskills.io/skill-creation/best-practices.
- [ ] All targeted skills apply description optimization guidance from https://agentskills.io/skill-creation/optimizing-descriptions.
- [ ] Improvement validation shows prompt-quality gains versus baseline without skills.
- [ ] Reusable script code is stored in `scripts/` using allowed tooling priorities.
- [ ] Tests are stored in `test/` and demonstrate at least 5% relative improvement where measurable.
- [ ] @ralphke reviewed and approved this spec before implementation tasks are executed.
