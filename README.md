# GitHub Copilot Workshop

This repository hosts a hands-on workshop for beginner, intermediate, and advanced developers to learn how to use GitHub Copilot effectively.

## Learning goals

- Build practical Copilot habits for everyday coding.
- Move from prompt quality and pair-programming fundamentals to agentic workflows.
- End with an automated issue-to-Copilot flow where tasks can be handled autonomously.

## Workshop tracks

- Beginner: prompt crafting, chat context, and safe code generation.
- Intermediate: test-driven workflows, refactoring, and review loops.
- Advanced: CI/CD + autonomous issue handling with Copilot-CLI coding agent.

See the full roadmap in doc/workshop-roadmap.md.

## Source material

The workshop content is curated from:

- [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) — primary IDE for all workshop participants
- [OpenSpec: a community-driven repository of best practices for prompt engineering and agent design.](https://github.com/Fission-AI/OpenSpec)
- [Agentic DevOps in action: Reimagining every phase of the developer lifecycle](https://developer.microsoft.com/blog/reimagining-every-phase-of-the-developer-lifecycle)
- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [awesome-copilot Learning Hub](https://awesome-copilot.github.com/learning-hub/)
- [GitHub Awesome Copilot](https://github.com/github/awesome-copilot)
- [VS Code .github build patterns](https://github.com/microsoft/vscode/tree/main/.github)
- [VS Code Copilot Agents App](https://code.visualstudio.com/docs/copilot/agents-app)

## Repository layout

- .github/prompts: prompt history recorded in operation order.
- .github/workflows: CI and Copilot automation workflows.
- doc: workshop guides, facilitator notes, and participant setup instructions (doc/setup.md).
- lab: participant exercises by level.
- src: optional source exercises.
- spec: optional specification for exercises.
- test: optional validation tests for exercises.

## Prerequisites

> **Primary IDE for this workshop:** [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) (bundled with VS Code Insiders). See **doc/setup.md** for installation and sign-in instructions before starting any lab.

- VS Code Insiders installed with the Agents application open
- GitHub account with an active Copilot subscription
- This repository cloned and trusted in the Agents app

## Quick start

1. Create issues from the Copilot task issue template.
2. Add the label copilot-task.
3. The workflow auto-routes the issue and asks Copilot to start work.
4. CI runs on pull requests so proposed changes are validated.

## Notes

- Automation requires GitHub Copilot-CLI coding agent availability on the repository/org.
- If Copilot-CLI cannot be auto-assigned in your org, the workflow leaves guidance comments so a maintainer can continue manually.
