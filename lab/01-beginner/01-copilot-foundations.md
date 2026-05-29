# Lab 01: Copilot Foundations (Beginner)

## Prerequisites

- **Primary IDE:** [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) (see doc/setup.md for setup)
- GitHub account with an active Copilot subscription
- This repository cloned and trusted in the Agents app

## Goal

Use Copilot Chat and inline completions to implement a small feature with clear requirements and validation checks, starting with a first working page in this repository.

## Getting Started

Your first task in this workshop is to make a tiny change that works end to end. Keep it simple: one static web page that you can open and read without any backend or framework setup.

1. Open this repository in the VS Code Agents application.
2. If prompted, trust the folder and reopen it in the devcontainer.
3. Create a new file at `src/hello-copilot.html`.
4. Ask Copilot to help you build a simple page with:
   - a title
   - one short paragraph about the workshop
   - one button or link
   - a little styling so it looks intentional
5. Open the file in your browser or preview pane and confirm the page renders.

Suggested starter prompt:

> Create a simple single-page HTML file for this workshop in `src/hello-copilot.html`. It should have a clear heading, a short welcome message, one call-to-action button, and a small amount of CSS so the page looks polished. Keep the code simple and self-contained.

Suggested acceptance criteria:

- The file exists at `src/hello-copilot.html`.
- The page renders with a visible heading and body copy.
- There is at least one interactive element on the page.
- The layout looks clean enough that you would be comfortable showing it to someone else.

## Exercises

1. Use the starter prompt above, then adjust it so Copilot matches your style and wording.
2. Write a prompt that includes:
   - Problem statement
   - Inputs and outputs
   - Constraints
   - Test expectations
3. Ask Copilot for an initial implementation.
4. Ask Copilot to create test cases and edge cases.
5. Compare generated code against your requirements and revise prompt quality.

## Success criteria

- You can open a working page in this repository and explain how it was created.
- Prompt includes objective, constraints, and acceptance criteria.
- Generated code passes tests you define.
- You can explain why each prompt revision improved outcomes.

## Suggested references

- awesome-copilot Learning Hub: Prompting modules
- GitHub Awesome Copilot: Prompt examples and best practices
