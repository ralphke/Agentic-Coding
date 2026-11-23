# Delta for sdlc-process

## MODIFIED Requirements

### Requirement: Spec Before Code

A complete OpenSPEC spec with scenarios MUST exist and be accepted before any implementation task is assigned, and managed customization changes MUST synchronize upstream before repo-local normalization.

#### Scenario: Implementation blocked without spec

- GIVEN a developer attempts to open a PR referencing a change
- WHEN the CI orchestrator checks for `openspec/changes/<change>/tasks.md`
- THEN the PR is blocked if tasks.md is missing or has no checked-off items
- AND the PR receives a `spec-required` label

#### Scenario: Spec triggers design and tasks

- GIVEN a complete `specs/<domain>/spec.md` delta with >=3 scenarios
- WHEN the Architect Agent reviews it
- THEN `design.md` is produced with ADRs and a component diagram
- AND `tasks.md` is produced with numbered, atomic, ordered tasks

#### Scenario: Upstream customization sync precedes local cleanup

- GIVEN the agentic-shared manifest pins an older release
- WHEN repository customization maintenance starts
- THEN the latest approved upstream release is resolved and synchronized first
- AND protected repo-local assets remain unchanged
- AND local cleanup is applied only after reviewing the resulting diff

#### Scenario: Copilot harness behavior is verified before retirement

- GIVEN a repository customization has an existing Local-harness implementation
- WHEN it is migrated or replaced
- THEN discovery is verified in a Copilot session
- AND representative behavior and tool activity are tested
- AND the legacy copy is retained until the replacement passes
