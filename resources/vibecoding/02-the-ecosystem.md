# Chapter 2: The Ecosystem

The vibe coding revolution didn't happen because of one tool. It happened because an entire ecosystem matured at the same time: AI models, smart editors, browser-based builders, and one-click deployment platforms all reached "good enough" within the same 18-month window.

## AI-Native IDEs

These aren't plugins bolted onto text editors. They're full development environments rebuilt around AI.

### Cursor

Cursor is the market leader: a VS Code fork with deep codebase-aware AI, multi-file editing through Composer, and autonomous background agents that can work on tasks while you do something else.

- Pricing: starts at $20 / mo
- Tradeoff: credit-based pricing can be unpredictable
- Best for: professional developers who want the most powerful all-in-one experience

### Windsurf

Windsurf, formerly Codeium, offers similar agentic capabilities through its Cascade system at a lower price point.

- Pricing: $15 / mo for Pro
- Positioning: strong value pick
- Notable: ranked #1 in LogRocket's AI Dev Tool Power Rankings

### Void

Void takes a different approach: fully open-source, privacy-first, and model-agnostic. You bring your own LLM, cloud or local, and pay nothing for the editor itself.

- Best for: developers who want transparency and no vendor lock-in

## CLI and Agentic Tools

For developers who live in the terminal.

### Claude Code

Claude Code is Anthropic's CLI agent. It reads your files, writes code, runs commands, and iterates autonomously.

- Strength: exceptionally capable for complex multi-file tasks
- Model access: Claude Opus 4.6 with 1M context
- Pricing: included with Claude Pro through Max plans

### GitHub Copilot CLI

GitHub Copilot CLI reached general availability in early 2026 with multi-model support, parallel subagents via `/fleet`, and deep GitHub integration.

- Supported models: Claude, GPT, Gemini
- Pricing: included with Copilot Pro at $10 / mo

### Aider

Aider is the open-source alternative: a terminal-based pair programmer that works directly with Git and creates tracked commits for every AI change.

- Pricing: free
- Compatibility: works with any LLM

## Browser-Based Builders

No IDE, no terminal, no local setup. Describe what you want and get a working app.

### Bolt.new

Bolt.new, from StackBlitz, generates complete full-stack apps in your browser via WebContainers.

- Features: Figma import, built-in databases, hosting
- Pricing: from $20 / mo
- Best for: rapid prototyping with everything in one place

### Lovable

Lovable made app creation feel like a conversation and became one of the fastest-growing software startups in history.

- Pricing: from $25 / mo
- Strength: predictable message-based pricing and deep Supabase integration
- Best for: non-technical founders

### v0 by Vercel

v0 specializes in frontend and produces especially clean React, Next.js, and Tailwind code.

- Pricing: from $20 / mo
- Strength: one-click Vercel deployment
- Best for: production-quality UI components

### Replit Agent

Replit Agent offers end-to-end autonomy in a browser IDE. It can build, test, and deploy apps, even integrating third-party services automatically.

- Pricing: from $20 / mo

## Autocomplete and Copilots

These are the classic AI coding assistants that live inside your existing editor.

### GitHub Copilot

GitHub Copilot remains the most widely adopted AI coding tool, now with multi-model support and agent mode.

- Pricing: free tier available, Pro at $10 / mo
- Positioning: the safe mainstream choice

### Tabnine

Tabnine targets enterprises with strict security requirements.

- Features: fully on-premises deployment, zero data retention, air-gapped operation
- Pricing: from $39 / user / mo
- Best for: high-compliance environments

### Amazon Q Developer

Amazon Q Developer is the natural choice for AWS-heavy teams.

- Strength: deep AWS integration and IP indemnity
- Pricing: free tier with unlimited completions

## The Models Behind It All

Every tool above is powered by one of these engines:

| Model | Strength | API Price (Input / 1M) |
| --- | --- | ---: |
| Claude Opus 4.6 | Best reasoning, 1M context | $5.00 |
| Claude Sonnet 4.6 | Fast and capable, best frontier value | $3.00 |
| GPT-4.1 | Optimized for code editing | $2.00 |
| GPT-4.1-nano | Cheapest capable model | $0.10 |
| Gemini 2.5 Pro | Strong multimodal, Google ecosystem | $1.25 |
| Gemini 2.5 Flash | Ultra-fast, great for autocomplete | $0.30 |
| Codestral | Open-weight, self-hostable | Varies |

## The Deploy Stack

Where vibe-coded apps go to live:

### Supabase

Supabase is the default backend: a managed Postgres database with auth, storage, and real-time subscriptions.

- Open-source
- Generous free tier
- Often the default backend for Lovable and Bolt.new projects

### Vercel

Vercel is the leading frontend deployment platform, especially for Next.js.

- Preview deployments on every commit
- Global edge network
- Natural home for v0-generated code
- Pricing: from $20 / mo

### Railway

Railway handles the backend services Vercel doesn't.

- Supports backend services, Docker containers, and managed databases
- Typical app cost: about $8-$15 / mo
- Common pairing: Vercel for frontend plus Railway for backend

## The Decision Tree

| If you need... | Start with... |
| --- | --- |
| A full AI-powered IDE | Cursor or Windsurf |
| Terminal-first AI coding | Claude Code or Aider |
| Build an app with zero setup | Bolt.new or Lovable |
| AI in your existing editor | GitHub Copilot |
| Enterprise with privacy requirements | Tabnine |
| A backend without backend knowledge | Supabase |
| Deploy and host | Vercel + Railway |

The ecosystem is moving fast. By the time you read this, some of these tools will have merged, pivoted, or been replaced by something better. That's the point: the barrier to building software keeps dropping.

The best tool is the one that gets you from idea to working product fastest.
