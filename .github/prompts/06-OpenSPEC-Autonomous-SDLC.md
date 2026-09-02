---
mode: agent
description: >
  Record of the prompt that established the Software Fabric autonomous SDLC
  framework in this repository. Serves as the reference for the overall design intent.
---

# Software Fabric — Autonomous SDLC Setup

This prompt established the comprehensive spec-driven autonomous SDLC process
for this repository using the OpenSPEC specification framework.

## What Was Created

### OpenSPEC Structure (`spec/openspec/`)
- `config.yaml` — OpenSpec project configuration with domain ownership and quality gates
- `specs/sdlc-process/spec.md` — End-to-end SDLC workflow source of truth
- `specs/personas/spec.md` — All 8 agent persona definitions and collaboration contracts
- `specs/idea-capture/spec.md` — Idea intake, validation, and proposal format
- `specs/security-standards/spec.md` — OWASP alignment and security gate rules
- `specs/testing-standards/spec.md` — Coverage requirements and test pyramid
- `specs/operations/spec.md` — Deployment, SLOs, monitoring, and runbooks
- `changes/README.md` — Changes directory documentation

### Templates (`spec/templates/`)
- `idea-to-spec.md` — Complete idea-to-OpenSPEC-proposal template

### Agent Personas (`.github/agents/`)
Eight specialized AI agent persona definitions:
- `product-owner.md` — Idea intake → proposal
- `architect.md` — Proposal → design + tasks
- `developer.md` — Tasks → implementation
- `qa-engineer.md` — Code → test suites
- `security-engineer.md` — Code → security report
- `code-reviewer.md` — Code → review approval
- `devops-sre.md` — Approved PR → staged deployment
- `operations-sre.md` — Deployed app → SLOs + archive

### Instructions (`.github/instructions/`)
- `openspec-workflow.instructions.md` — Applied to `spec/openspec/**`
- `sdlc-fabric.instructions.md` — Applied globally

### Skills (`.github/skills/`)
- `idea-to-spec/skill.md` — Product Owner skill
- `spec-to-design/skill.md` — Architect skill
- `test-generation/skill.md` — QA Engineer skill
- `security-review/skill.md` — Security Engineer skill
- `pr-review/skill.md` — Code Reviewer skill
- `deploy-pipeline/skill.md` — DevOps/SRE skill

### Prompts (`.github/prompts/`)
- `opsx-propose.prompt.md` — Start a new change
- `opsx-apply.prompt.md` — Implement a change
- `opsx-verify.prompt.md` — Verify implementation against spec
- `sdlc-kickoff.prompt.md` — Full autonomous SDLC kickoff

### VS Code MCP (`.vscode/mcp.json`)
- `openspec-filesystem` — Spec folder filesystem access
- `github-mcp` — GitHub API integration

### GitHub Automation
- `.github/workflows/sdlc-orchestrator.yml` — Stage-gate orchestration workflow
- `.github/ISSUE_TEMPLATE/idea-capture.yml` — Structured idea submission

## The Software Fabric Pipeline

```
[Idea] → [Proposal] → [Spec+Design] → [Tasks] → [Code]
       → [Tests] → [Security] → [Review] → [Deploy] → [Operate+Archive]
```

Each stage is automated, gated by PR labels (`stage:*`), and owned by a
specific agent persona with defined inputs, outputs, and handoff protocols.

## Key Design Decisions

1. **OpenSPEC as the spec format** — fluid, iterative, brownfield-friendly
2. **Delta specs** — changes describe what's ADDED/MODIFIED/REMOVED, not full rewrites
3. **PR labels as stage gates** — `stage:design` → `stage:implement` → ... → `archived`
4. **Quality gates** — tests (≥80%), security (no HIGH+), coverage, CI green
5. **Rollback-first operations** — auto-rollback on smoke test failure within 5 minutes
6. **SLO-driven archiving** — changes only archived when SLOs are configured and stable
