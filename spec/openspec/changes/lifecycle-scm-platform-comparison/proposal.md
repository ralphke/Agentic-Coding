# Proposal: Compare Source-Control and Work-Management Platforms by Lifecycle Phase

**Change Slug:** `lifecycle-scm-platform-comparison`
**Status:** Accepted
**Date:** 2026-07-27

## Intent

Extend the lifecycle AI engineering reference with the native capabilities of
GitHub, GitLab, and Atlassian across every lifecycle phase. Help readers decide
when a platform capability is sufficient and when a listed specialist product
has a demonstrated, non-duplicative advantage.

## Scope

- Add a lifecycle matrix for GitHub, GitLab, and Atlassian.
- Add a comparative SWOT analysis against the reference's listed solutions.
- Link capability claims to vendor documentation and retain availability caveats.

## Out of Scope

- Selecting a platform for a specific organization.
- Replacing vendor validation, pilots, procurement, or security review.
- Publishing feature availability or pricing commitments beyond vendor sources.

## Scenarios

### Scenario: Evaluate a planning capability

- GIVEN a team is comparing its source-control or work-management platform to
  Notion AI, Atlassian Rovo, and Miro AI
- WHEN the team reads the Define & plan row
- THEN it can identify the platform's native planning and AI capability
- AND it can see the specialist capability that remains differentiated

### Scenario: Evaluate delivery controls

- GIVEN a team uses GitHub, GitLab, or Atlassian for source control
- WHEN the team reads the Test & validate and Release & deploy rows
- THEN it can distinguish native CI/CD and agent-assisted capabilities from
  mabl, Applitools, Diffblue, Harness, and LaunchDarkly AgentControl

### Scenario: Evaluate security and optimization coverage

- GIVEN a team is considering a security or codebase-intelligence product
- WHEN the team reads the Monitor & secure and Optimize & improve rows and SWOT
  analysis
- THEN it can identify native coverage, specialist gaps, and duplicate-control
  risks before starting a pilot

## Acceptance Criteria

- [x] The reference covers GitHub, GitLab, and Atlassian in all six lifecycle phases.
- [x] Each phase identifies the relevant differentiated specialist capabilities.
- [x] A SWOT analysis compares the three platforms with the listed solutions.
- [x] Vendor capability claims link to vendor documentation and include an availability caveat.
