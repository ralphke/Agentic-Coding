# Lab 02: Spec-Driven Development (Intermediate)

## Prerequisites

- **Primary IDE:** [VS Code Agents application](https://code.visualstudio.com/docs/copilot/agents-app) (see doc/setup.md for setup)
- GitHub account with an active Copilot subscription
- Completed lab/02-intermediate/01-tests-and-refactor.md

## Goal

Learn to write a lightweight spec *before* asking Copilot to implement anything. A clear spec gives the agent an explicit contract to work from, dramatically improving the quality and predictability of generated code.

## Background

When you delegate work to an AI agent, the output quality is bounded by the clarity of the input. Vague prompts produce vague implementations. A **spec** is a short structured document that captures:

- **What** you want to change and why (proposal)
- **How** it should behave (requirements and scenarios)
- **How** it will be built (design notes)
- **What** needs to be done (tasks checklist)

This pattern comes from [OpenSpec](https://github.com/Fission-AI/OpenSpec), a community-driven spec framework. See `spec/spec-template.md` for the blank template and `spec/example-feature-spec.md` for a filled example.

## Exercises

### Exercise 1 — Prompt without a spec (baseline)

1. Pick a small feature: *"Add a function that validates an email address."*
2. Ask Copilot directly:

   ```
   Write a function that validates an email address.
   ```

3. Note the result: What edge cases did it handle? Did it add tests? How confident are you in the behavior at the boundaries?

---

### Exercise 2 — Write a spec first

Use `spec/spec-template.md` as your starting point. Fill in all four sections for the same email-validation feature:

**Proposal** — one paragraph describing the change and why it matters.

**Requirements / Scenarios** — write at least 3 scenarios in Given/When/Then format:

```
Scenario: Valid email accepted
  Given a string in the format "user@domain.tld"
  When validateEmail is called
  Then it returns true

Scenario: Missing @ symbol rejected
  Given a string "userdomain.tld"
  When validateEmail is called
  Then it returns false

Scenario: Empty string rejected
  Given an empty string ""
  When validateEmail is called
  Then it returns false
```

**Design** — note the function signature, return type, and any library constraints.

**Tasks** — break work into numbered steps (implement function, write unit tests, add to module exports).

---

### Exercise 3 — Prompt with your spec

1. Attach your spec to Copilot's context (paste or use `@` file reference).
2. Ask:

   ```
   Implement the tasks in this spec. Follow the scenarios exactly.
   ```

3. Compare the output with Exercise 1. Did coverage improve? Were the edge cases reflected?

---

### Exercise 4 — Iterate on the spec, not the prompt

1. Identify one gap in the generated code (e.g., international domains, subdomains).
2. **Update the spec** to add the new scenario — do not just re-prompt.
3. Re-run the Copilot request with the updated spec.

The key habit: **fix the spec, then re-run the agent**. This keeps requirements in a durable artifact rather than buried in chat history.

---

### Exercise 5 — Reflect

Answer these questions in a short note:

- Which exercise produced code you trusted more? Why?
- What would happen if you handed your spec (not your prompt) to a teammate?
- How does spec quality change what a code review looks like?

## Success criteria

- You have a written spec with all four sections complete.
- Generated code matches every scenario in your spec.
- You iterated at least once by updating the spec rather than reprompting.
- You can explain the difference between a prompt and a spec.

## Suggested references

- [OpenSpec concepts](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md) — fluid, iterative spec philosophy
- [OpenSpec OPSX workflow](https://github.com/Fission-AI/OpenSpec/blob/main/docs/opsx.md) — `/opsx:propose` quick-start
- `spec/spec-template.md` and `spec/example-feature-spec.md` in this repository
