# Lab 02: Full Agentic Developer Lifecycle (Advanced)

## Goal

Walk through the complete agentic DevOps lifecycle — from raw idea to deployed, monitored feature — using spec-backed issues, Copilot coding agent delegation, CI validation, and iterative review.

## Background

[Agentic DevOps](https://developer.microsoft.com/blog/reimagining-every-phase-of-the-developer-lifecycle) reshapes every phase of software delivery. Rather than autocomplete, agents take on entire classes of tasks with your guidance. The lifecycle looks like this:

```
Idea → PRD → Spec-backed Issue → Copilot Coding Agent → PR Review → CI → Deploy → Monitor
```

Each hand-off point requires a clear, structured artifact so the next actor (human or agent) knows exactly what is expected.

## Prerequisites

- **Primary IDE:** [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) — you will use the Agents app as the central interface for all phases (see doc/setup.md)
- Completed lab/02-intermediate/02-spec-driven-development.md
- Copilot coding agent enabled for your org/repository
- GitHub Actions enabled
- Maintainer access to create issues and manage labels

## Phase 1 — Idea to PRD

1. Start with a one-sentence idea:

   > *"Add a health-check endpoint that returns service status and version."*

2. Expand it into a **Product Requirements Document (PRD)** using Copilot on GitHub.com or in agent mode:

   ```
   Turn this idea into a short PRD. Include: problem statement, target users,
   key user flows, acceptance criteria, and out-of-scope items.
   ```

3. Review the PRD. Remove anything vague. Add at least two explicit acceptance criteria.

---

## Phase 2 — PRD to Spec

Convert your PRD into a spec using `spec/spec-template.md`:

- **Proposal**: one paragraph distilled from the PRD
- **Scenarios**: at least three Given/When/Then cases from the acceptance criteria
- **Design**: endpoint path, response schema (JSON), HTTP status codes
- **Tasks**: numbered implementation steps

Save the spec as `spec/changes/health-check/proposal.md` (create the folder).

---

## Phase 3 — Spec to Issue

1. Create a GitHub issue from the **Copilot Task** issue template.
2. Paste your spec into the issue body — this becomes the agent's source of truth.
3. Add the `copilot-task` label.
4. Confirm the routing workflow fires: check Actions → copilot-task-router run.

---

## Phase 4 — Copilot Coding Agent

1. Watch Copilot open a draft pull request.
2. Review the draft PR against your spec scenarios — not just the code, but the behavior:
   - Does the endpoint return the right schema?
   - Are the status codes correct?
   - Are edge cases (service degraded, missing config) handled?
3. Leave structured feedback on the PR tied to specific spec scenarios:

   ```
   Scenario "unhealthy service" (spec §3.2) is not covered.
   The endpoint should return HTTP 503 with {"status":"degraded"} when DB is unreachable.
   ```

4. Let Copilot iterate. Merge only when all spec scenarios pass.

---

## Phase 5 — CI Guardrails

Verify CI checks on the pull request:
- All existing tests pass.
- The new endpoint has tests that map to spec scenarios.
- No secrets or unsafe patterns in the diff.

If CI fails, update the spec to reflect any requirement that changed, then comment on the PR.

---

## Phase 6 — Observe and Iterate

After merging, imagine a monitoring alert fires:

> *"Health endpoint latency P99 > 2 s under load."*

1. Write a new scenario in the spec:

   ```
   Scenario: Health endpoint responds under load
     Given 100 concurrent requests
     When /health is called
     Then response time P99 is under 500ms
   ```

2. Create a new issue referencing the updated spec.
3. Assign to Copilot. Observe how a spec-backed issue produces a more targeted fix than a bare bug report.

---

## Reflection

- How did writing the spec before the issue change what the agent produced?
- Where in the lifecycle did you have to course-correct most? What artifact fixed it?
- How would this workflow scale to a team of five engineers?

## Success criteria

- You produced a PRD → spec → issue → PR → merge cycle for one feature.
- Every PR review comment traced back to a spec scenario.
- CI passed before merge.
- You updated the spec at least once (Phase 6 scenario).

## Suggested references

- [Agentic DevOps in action](https://developer.microsoft.com/blog/reimagining-every-phase-of-the-developer-lifecycle) — end-to-end lifecycle walkthrough
- [OpenSpec OPSX workflow](https://github.com/Fission-AI/OpenSpec/blob/main/docs/opsx.md) — `/opsx:propose` and `/opsx:apply`
- lab/03-advanced/01-agentic-cicd.md — issue routing and CI automation setup
