# Workshop Roadmap

## Prerequisites

Before attending the workshop, every participant must complete the setup steps in **doc/setup.md**:

- Install [VS Code Insiders](https://code.visualstudio.com/insiders/) — the Agents application is bundled with it
- Open the **VS Code Agents application** — this is the primary IDE for all labs
- Sign in with a GitHub account that has an active Copilot subscription
- Clone and trust this repository inside the Agents app

> The Agents application provides the agent-first interface where chat is the primary workflow. All exercises are designed to be run there.

## Audience levels

### Beginner

Outcome: write clear prompts, provide context correctly, and validate generated code.

Labs:

- lab/beginner/01-copilot-foundations.md

### Intermediate

Outcome: use Copilot with tests, refactors, and code review feedback loops. Write structured specs that give agents a clear contract to implement from.

Labs:

- lab/intermediate/01-tests-and-refactor.md
- lab/intermediate/02-spec-driven-development.md

### Advanced

Outcome: build an issue-driven CI/CD flow where Copilot can autonomously propose fixes/features through pull requests, guided by spec artifacts at every stage.

Labs:

- lab/advanced/01-agentic-cicd.md
- lab/advanced/02-agentic-lifecycle.md

## Curriculum flow

1. Foundations and prompt quality.
2. Test-first development and refactor cycles.
3. Spec-first development — proposal, scenarios, design, tasks.
4. Agentic automation in GitHub issues + pull requests.
5. Full agentic DevOps lifecycle: idea → PRD → spec → code → deploy → monitor.
6. Guardrails and CI checks.

## Content sourcing

All modules should reference and adapt ideas from:

- [awesome-copilot Learning Hub](https://awesome-copilot.github.com/learning-hub/)
- [GitHub Awesome Copilot](https://github.com/github/awesome-copilot)
- [VS Code .github examples for workflow style](https://github.com/microsoft/vscode/tree/main/.github)
- [OpenSpec: spec-driven agentic development framework](https://github.com/Fission-AI/OpenSpec)
- [Agentic DevOps in action](https://developer.microsoft.com/blog/reimagining-every-phase-of-the-developer-lifecycle)
- [Muster an Universal Control Plane for AI Agents and MCP-Server Automation](https://github.com/giantswarm/muster)

## Contribution rules for this workshop

- Every workshop build/update prompt must be saved in .github/prompts in chronological order.
- Keep each lab runnable with minimal prerequisites.
- Include expected outcomes and validation criteria in every lab.
