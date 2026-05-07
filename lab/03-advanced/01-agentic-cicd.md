# Lab 01: Agentic CI/CD with Copilot (Advanced)

## Goal

Build an automated GitHub workflow where qualifying issues are routed to Copilot and validated through CI when pull requests are created.

## Prerequisites

- **Primary IDE:** [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) — open the Agents app and start sessions from there (see doc/setup.md)
- GitHub Copilot coding agent is enabled for your org/repository
- Actions are enabled in the repository
- Maintainers can manage issues and workflow permissions

## Steps

1. Create an issue using the Copilot Task template.
2. Add label copilot-task.
3. Confirm the routing workflow:
   - attempts to assign issue to Copilot
   - posts an @copilot kickoff comment with task details
4. Wait for Copilot to open a pull request.
5. Verify CI checks pass on the pull request.
6. Review, merge, and close the issue.

## Guardrails

- Require acceptance criteria in the issue template.
- Keep CI checks required for merge.
- Use scoped labels to distinguish bug fixes vs feature work.

## Success criteria

- A task issue triggers automated Copilot routing.
- Copilot produces a pull request tied to the issue.
- CI validates the proposed change before merge.
