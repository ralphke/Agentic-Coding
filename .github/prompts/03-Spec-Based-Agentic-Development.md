# Prompt 03: Spec-Based Agentic Development Workshop Improvements

## Source prompt

Improve this repo with the new resources shared in the README.md to educate the participants about spec based agentic development.

## Source materials incorporated

- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — spec-first framework; `/opsx:propose → apply → archive` workflow; proposal/scenarios/design/tasks artifact structure
- [Agentic DevOps in action](https://developer.microsoft.com/blog/reimagining-every-phase-of-the-developer-lifecycle) — full agentic developer lifecycle: idea → PRD → spec → coding agent → review → deploy → monitor

## Actions performed

1. Created intermediate lab on spec-driven development (proposal, Given/When/Then scenarios, design, tasks pattern).
2. Created advanced lab on the full agentic DevOps lifecycle (PRD → spec-backed issue → coding agent → CI → monitor).
3. Created `spec/spec-template.md` — reusable blank spec template for participants.
4. Created `spec/example-feature-spec.md` — filled example (email validation) showing what a good spec looks like.
5. Updated `doc/workshop-roadmap.md` to include new labs in both tracks and add spec-based agentic development to the curriculum flow.
6. Updated `.github/copilot-instructions.md` to register new files and the spec/ directory.

## Files created

- lab/02-intermediate/02-spec-driven-development.md
- lab/03-advanced/02-agentic-lifecycle.md
- spec/spec-template.md
- spec/example-feature-spec.md
- .github/prompts/03-Spec-Based-Agentic-Development.md

## Files updated

- doc/workshop-roadmap.md
- .github/copilot-instructions.md
