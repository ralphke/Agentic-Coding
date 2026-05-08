# Chapter 5: Security

Vibe coding makes building software faster than ever. It also makes building insecure software faster than ever. The real question isn't whether to use AI. It's how to use it without getting burned.

## The State of Play

A scan of 100 publicly deployed vibe-coded apps in 2026 found 318 vulnerabilities, 89 of them critical.

- 65% of apps had at least one security issue
- 41% had API keys exposed in source code
- 70% lacked CSRF protection

Across 5,600 vibe-coded applications, researchers found over 2,000 vulnerabilities, more than 400 exposed secrets, and 175 instances of exposed personal data, including medical records and bank account numbers.

AI-generated code introduces more issues and more security vulnerabilities than human-written code because LLMs optimize for code that works, not code that defends. Security is adversarial by nature. AI is optimized for the common case.

As one researcher put it:

> "They're doing exactly what you asked - writing code that works. But nobody asked 'also make it secure.'"

## The Usual Suspects

The same vulnerability patterns appear repeatedly in AI-generated code:

- SQL injection from string interpolation instead of parameterized queries
- Cross-site scripting, significantly more common than in human code
- Hardcoded secrets such as API keys, passwords, and tokens
- Missing or inverted authentication and authorization logic
- Phantom packages, where the AI recommends dependencies that do not exist and attackers later register them

## The Disasters

### Moltbook (January 2026)

An AI-built social network exposed 1.5 million API tokens, 35,000 email addresses, and thousands of private messages within days of launch. A Supabase API key sat in client-side JavaScript with no Row Level Security.

### EnrichLead (March 2025)

A SaaS product built entirely with Cursor AI kept all security logic on the client side. Users could bypass paid features by changing a single value in the browser console. The project shut down within 72 hours.

Wiz Security researchers summarized the broader problem clearly: the barrier to building has dropped dramatically, but the barrier to building securely has not kept pace.

## It's Getting Better, But Not Enough

The 2026 tooling has improved:

- Claude Code Security can find vulnerabilities across production codebases and suggest patches with human approval
- Black Duck Signal connects scanning into AI coding workflows via MCP
- Lovable now enables Row Level Security by default and added more database and dependency checks
- Windsurf integrated Snyk for vulnerability remediation
- Vibe App Scanner offers URL-based scanning for public apps
- Palo Alto Networks published the SHIELD framework for vibe coding governance

But even with strong models and explicit security reminders, secure and correct code generation is still far from guaranteed.

## Expertise Matters - A Lot

Your technical knowledge is still the biggest factor in whether your vibe-coded app is secure.

Studies found that programming experience significantly improves code security and cannot be fully substituted by AI. The polished appearance of AI-generated code often makes developers more confident than they should be.

The implication is simple: the more you understand what the AI is generating, the safer your code.

## What You Can Do

Even generic guidance like "make sure the code follows best practices for secure code" can reduce vulnerabilities significantly. Better yet, use a two-stage workflow where the AI writes the code and then reviews it as a security engineer.

### Essential Checklist

1. Add security requirements to every prompt.
2. Run automated scanning with SAST and secret-scanning tools.
3. Verify every dependency before installing it.
4. Use infrastructure-level protection such as reverse proxies, Zero Trust controls, or properly configured RLS.
5. Keep humans in the loop for authentication, payments, data access, and personal information.
6. Ask the AI to review its own output from a security perspective.

## The Paradox

AI is both the problem and part of the solution. It introduces vulnerabilities faster than humans, but AI-powered scanners can also review code at machine speed and catch bugs people miss.

The future of secure vibe coding is not human or AI. It's both layers working together.

## The Bottom Line

The joke goes that the "S" in vibe coding stands for security. It's funny because, too often, it's true.

The gap isn't only in the tooling anymore. It's in the habits. Build fast, but build like someone's trying to break in, because they are.
