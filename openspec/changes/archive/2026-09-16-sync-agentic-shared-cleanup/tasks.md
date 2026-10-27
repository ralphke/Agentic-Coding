# Tasks: Clean Up and Sync Agentic Shared Assets

**Change Slug:** `sync-agentic-shared-cleanup`
**Status:** Planned
**Date:** 2026-09-16

## Phase 1 - Discovery and Design Confirmation

- [x] T01 [S] - Inspect the repository for `.agentic-shared.yml`, the `agentic-shared` local store, synchronization workflows, and reserved local extension paths. No concrete manifest, workflow, or ownership declaration was found in the workspace search; implementation is blocked pending the source boundary.
- [x] T02 [S] - Run the OpenSpec CLI store operation for `agentic-shared` and capture the exact command, exit status, resolved repository path/revision, and source date. Do not access repository content through an alternate path.
- [x] T03 [S] - Validate `.agentic-shared.yml` through the resolved OpenSpec CLI store content, including syntax, required source/revision fields, managed paths, local extension paths, and operational sync settings.
- [x] T04 [M] - Produce a before-sync inventory of managed, local, stale, duplicated, and locally modified paths.

## Phase 2 - Reconciliation

- [x] T05 [M] - Reconcile the manifest so managed shared assets and repository-local extensions are explicitly classified.
- [x] T06 [M] - Apply the selected shared revision to managed paths without overwriting local extensions or unrelated repository content.
- [x] T07 [M] - Remove stale or duplicated files only when manifest ownership is confirmed, and record every removal.
- [x] T08 [M] - Detect unresolved local modifications and stop before overwrite when a conflict is unsafe or ambiguous.

## Phase 3 - Evidence and Validation

- [x] T09 [S] - Produce the synchronization review summary with the OpenSpec CLI command/output, source revision/date, changed paths, removed paths, preserved local paths, conflicts, and rollback information.
- [x] T10 [S] - Run OpenSpec structure, prompt ordering, workflow, and repository validation checks and attach their results to the summary.
- [x] T11 [S] - Scan changed files and generated artifacts for credentials, tokens, and machine-specific metadata.
- [x] T12 [S] - Confirm all proposal acceptance criteria are represented by implementation evidence and update this checklist before handoff.
