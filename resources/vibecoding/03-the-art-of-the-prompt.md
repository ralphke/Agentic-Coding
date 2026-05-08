# Chapter 3: The Art of the Prompt

If vibe coding has a core skill, this is it. The quality of what the AI builds is directly proportional to the quality of what you ask for. A vague prompt produces vague code. A precise prompt produces precise code.

## Prompt Anatomy

Every effective prompt has four components:

### Context

What the AI needs to know before it starts: your tech stack, existing code patterns, and the problem domain.

Example:

> "I'm building a Next.js app with Supabase."

That sets very different expectations from:

> "I'm working on an embedded C system."

### Task

What you want the AI to do, broken into atomic pieces.

Instead of:

> "Build me a dashboard."

Use something like:

> "Create a React component that displays a sortable table of user transactions with columns for date, amount, description, and status."

### Constraints

The rules the output must follow.

Examples:

- Use parameterized queries
- Don't hardcode secrets
- Follow the existing naming convention
- Keep the file under 200 lines
- Use TypeScript strict mode

### Iteration Directive

How the AI should handle uncertainty.

Examples:

- If you're unsure about the database schema, ask before generating
- If a dependency doesn't exist, suggest an alternative

KD's ETL prompt and Priya's bakery dashboard prompt both work because they cover these elements, even though their styles are completely different.

## What Makes Prompts Fail

### Too Vague

> "Build me a web app for my business."

The AI will usually produce something generic and useless. You'll iterate endlessly and still not get what you need.

### Too Prescriptive on Implementation

If you specify every hook, endpoint, and state variable, you're just writing code with extra steps.

Instead of this:

> "Use a useEffect hook with a dependency array of [userId] to fetch from /api/users/{id} and store it in state."

Prefer this:

> "When the user profile page loads, fetch and display the current user's data. Handle loading and error states."

### Missing Security Context

Unless you explicitly say things like "validate input," "use parameterized queries," or "add authentication," the AI often won't. Even a generic instruction like "follow security best practices" materially reduces vulnerabilities.

### Hallucination Traps

"Use the best library for X" invites the AI to hallucinate a package that doesn't exist.

Better options:

- Name a specific library
- Ask for a well-maintained library with evidence like downloads or GitHub stars

### Context Overload

Dumping your entire codebase into a prompt doesn't help. The AI loses focus. Feed it the specific files and interfaces it needs.

## Patterns That Work

### The Specification Pattern

Write a detailed spec before touching the AI. Define inputs, outputs, data types, error cases, and constraints. Then translate that into a prompt.

Best for: complex backend work, APIs, and data pipelines.

### The Conversational Pattern

Describe what you want like you're talking to a smart colleague. Focus on the what and why. Let the AI work out the how.

Best for: UI, prototypes, and domain-specific tools.

### The Speedrun Pattern

Start with a mockup or screenshot, say "build this," and iterate quickly. If it goes sideways after a few attempts, restart.

Best for: MVPs, hackathons, and idea exploration.

### The Self-Reflection Pattern

Use a two-stage process:

1. Build the feature.
2. Ask the AI to review its own output as a senior security engineer.

This catches a surprising number of issues.

### The Incremental Pattern

Don't ask for the whole app at once. Build module by module:

1. Create the database schema
2. Review it
3. Create the API endpoints
4. Review them
5. Build the frontend against those endpoints

Each step builds on verified output.

## Anti-Patterns

### The "Fix It" Loop

Pasting an error and saying "fix it" over and over often makes the code worse after a few rounds. If two attempts don't work, restate the problem from scratch with better context.

### The Sunk Cost Prompt

If you've already spent 20 messages on bad output, don't keep going just because you've invested time. A fresh conversation with a better prompt often gets you further in five minutes than fifty iterations on a bad foundation.

### The Copy-Paste Marathon

Copying code between multiple AI sessions without understanding it creates Frankenstein code that neither you nor the AI can debug coherently.

### Prompt Injection Blindness

Asking the AI to process untrusted input inside a prompt without sanitization is a security vulnerability, not just a workflow mistake.

## The Meta-Skill

The deeper skill isn't any one prompting technique. It's knowing how to decompose a problem into AI-sized pieces: small enough that the AI can solve them reliably, but large enough that you're not micromanaging every line.

This is the same skill that makes someone good at delegating to humans: clear scope, clear constraints, clear success criteria, and the judgment to evaluate the result.

The best vibe coders aren't the best prompters. They're the best thinkers.

Or, as DeepSeek R1 put it in feedback on this whitebook:

> "Vibe coding is a fundamental abstraction shift from specification-by-implementation to specification-by-intent."

You're no longer telling the computer how to do something. You're telling it what you want.
