# Proposal: Clean Up and Sync Agentic Shared Assets

> **Change slug:** `sync-agentic-shared-cleanup`  
> **Priority:** P1  
> **Affected domains:** `sdlc-process`, `personas`, `idea-capture`  
> **Submitter:** Product Owner Agent  
> **Created:** 2026-09-16  
> **Status:** Accepted

## Intent

The repository consumes shared Software Fabric assets from the local OpenSpec store identified as `agentic-shared`, but the current checkout may contain stale, duplicated, or locally modified managed files. This makes it difficult to determine which agents, skills, prompts, instructions, and workflows are canonical and increases the risk of drift between this repository and the shared source.

This change will clean up managed assets and apply the latest approved version from the local `agentic-shared` store. Repository-specific workshop content and approved local extensions will remain owned by this repository. The result should be a consistent, reviewable checkout with clear ownership boundaries and validation evidence.

## Scope

- Inspect the `agentic-shared` local OpenSpec store and determine the latest approved version or revision.
- Reconcile the repository manifest and shared-asset ownership configuration with that source.
- Remove stale or duplicated managed assets when they are superseded by the canonical source.
- Apply the latest shared agents, skills, prompts, instructions, and workflows within the configured managed paths.
- Preserve repository-local customizations under reserved `local/` paths or other explicitly local manifest entries.
- Detect and document conflicts between shared updates and local changes before overwriting content.
- Validate OpenSpec structure, prompt ordering, workflow structure, and managed-asset consistency after synchronization.
- Record the source revision, changed paths, conflicts, removals, and validation results for review.

## Out of Scope

- Rewriting the canonical `agentic-shared` source or publishing changes upstream.
- Changing workshop labs, documentation, environment setup, or other repository-owned content unless required to repair a shared-asset integration.
- Introducing new agent personas, skills, prompts, or workflows unrelated to the latest shared source.
- Silently overwriting local customizations or deleting files without ownership and conflict checks.
- Archiving unrelated in-flight OpenSpec changes.

## Approach

Use the repository's existing shared-asset manifest and synchronization workflow as the source of truth for managed paths. First inventory the current checkout and local-store revision, then classify each affected path as managed, local, stale, duplicated, or conflicting. Apply the latest canonical content only to managed paths, retain local extensions in their reserved locations, and produce a deterministic change summary.

Run the repository's OpenSpec and CI validation checks after synchronization. Any conflict that cannot be resolved from the manifest or ownership rules will remain visible and block completion until explicitly reviewed. The sync must be reversible by restoring the previous manifest revision and managed files.

## Scenarios

### Scenario: Latest shared assets are applied

- GIVEN the local OpenSpec store `agentic-shared` contains a newer approved revision
- WHEN the synchronization change is applied
- THEN the repository's managed shared assets are updated to that revision
- AND the applied revision and changed paths are recorded for review

### Scenario: Local extensions are preserved

- GIVEN a repository-local agent, skill, prompt, instruction, or workflow is declared under a reserved local path
- WHEN the shared assets are synchronized
- THEN the local extension remains unchanged
- AND the synchronization report identifies it as repository-owned

### Scenario: Stale managed assets are cleaned up

- GIVEN a managed asset exists in the repository but no longer exists in the canonical `agentic-shared` revision
- WHEN the synchronization reconciliation runs
- THEN the stale asset is removed only if the manifest marks it as managed
- AND the removal is listed in the review summary

### Scenario: Conflicting local changes block unsafe replacement

- GIVEN a managed file has repository changes that are not represented as an approved local extension
- WHEN the canonical shared revision changes that file
- THEN the synchronization reports the conflict
- AND it does not silently overwrite the local content
- AND completion is blocked until the conflict is resolved or explicitly accepted

### Scenario: Validation catches incomplete synchronization

- GIVEN the synchronization has completed
- WHEN the repository validation checks run
- THEN OpenSpec structure, managed-path ownership, prompt ordering, and workflow validation pass
- AND any failed check identifies the affected path and required remediation

## Acceptance Criteria

- [x] The repository is synchronized to the latest available approved revision from the local OpenSpec store with id `agentic-shared`.
- [x] The manifest and synchronization report record the selected `agentic-shared` revision and source date.
- [x] The manifest accurately identifies managed shared assets and repository-local extensions.
- [x] Stale or duplicated managed assets are removed only when ownership is confirmed, with removals documented.
- [x] Local customizations and reserved `local/` extensions are preserved without silent overwrites.
- [x] Any unresolved synchronization conflicts are reported and prevent the change from being marked complete.
- [x] OpenSpec structure, prompt ordering, workflow, and repository validation checks pass after synchronization.
- [x] A review summary records the source revision, changed files, removed files, conflicts, and validation evidence.

## Affected Domains

- `sdlc-process` — shared-asset synchronization, ownership boundaries, validation, and rollback.
- `personas` — updates to managed agent definitions and stage handoffs.
- `idea-capture` — proposal and change lifecycle artifacts used to coordinate the cleanup.

## Stakeholders

| Role | Name / Team | Interest |
|------|-------------|----------|
| Requestor | Repository maintainer | Wants a clean checkout with current shared assets |
| Product Owner | AI Agent | Defines scope and acceptance criteria |
| Shared Asset Owner | `agentic-shared` maintainers | Owns canonical reusable assets |
| Repository Maintainer | Local workshop team | Owns local content and approves conflicts |

## Success Metrics

- **Primary:** All managed assets match the selected `agentic-shared` revision after synchronization.
- **Secondary:** No unexplained managed/local ownership conflicts remain.
- **Guard rail:** Repository-owned workshop content and approved local extensions are unchanged.

## Technical Notes

- Use the existing `.agentic-shared.yml` manifest and synchronization workflow when available.
- Preserve a before/after inventory so the change can be reviewed and rolled back.
- Do not commit credentials, local store secrets, or generated machine-specific metadata.

## Delta Spec References

Domains to update:

- `specs/sdlc-process/spec.md` — synchronization and ownership validation behavior.
- `specs/personas/spec.md` — managed persona source and handoff consistency.
- `specs/idea-capture/spec.md` — change proposal coordination where applicable.

## Linked Resources

- **Local OpenSpec store:** `agentic-shared`
- **Repository manifest:** `.agentic-shared.yml` when present
- **Synchronization workflow:** `.github/workflows/sync-agentic-shared.yml` when present
- **Design doc:** [design.md](./design.md) *(created by Architect Agent)*
- **Tasks:** [tasks.md](./tasks.md) *(created by Architect Agent)*
