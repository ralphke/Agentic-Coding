# Chapter 6: Legal and IP

AI writes the code. But who owns it? Who is liable when it breaks? And what happens when the AI copies someone else's work? These questions do not have clean answers yet, but ignoring them is not an option.

## Who Owns AI-Generated Code?

Major AI providers such as OpenAI, Anthropic, and Google contractually assign output ownership to users. In that narrow sense, you prompt it and you own it.

But copyright law is messier. Courts in the United States and Europe have reinforced the view that purely AI-generated content cannot itself be copyrighted. If no human made meaningful creative contributions, there may be nothing to protect.

The practical result is awkward:

- You may own the output contractually because the provider does not claim it
- You may still be unable to enforce copyright over purely AI-generated portions
- Copyright protection is stronger where you add substantial human contribution through editing, integration, or architecture

Document your human contributions carefully.

## The GPL Problem

One of the biggest active legal concerns is whether AI coding tools can reproduce licensed code without preserving the required notices or attribution.

The risk to organizations is straightforward: if an AI tool reproduces GPL-licensed code and you ship it in a proprietary product, you may be violating that license. The provider's terms of service do not shield you from third-party claims.

### Practical Response

- Run Software Composition Analysis tools on AI-generated code
- Enable duplicate detection where available
- Treat AI output like code from an unknown contributor and review it accordingly

## Liability: Who's Responsible?

No court has definitively resolved all liability questions around AI-generated code, but the practical trajectory is clear: the developer or organization that ships the code remains responsible for it.

"The AI suggested it" is not a legal defense, just as "I copied it from Stack Overflow" never was.

### Emerging Developments

- Some cyber insurance policies exclude damages from unverified AI output
- Legislatures are creating new rights of action for AI-related harms
- Conversations with AI platforms may be discoverable in litigation

Anything you paste into an AI system could later matter in court.

## The EU AI Act

AI coding tools built on general-purpose AI models fall under the GPAI provisions of the EU AI Act.

Key obligations for providers include:

- Maintaining detailed technical documentation
- Publishing summaries of copyrighted training data used
- Demonstrating copyright compliance in training data sourcing
- Submitting documentation to regulators on request

For organizations using these tools, the burden is practical rather than theoretical: know which tools are compliant, what data you send to them, and whether your use case triggers additional obligations.

## Audit Trails Are Coming

The direction is clear: organizations will increasingly need to prove what was AI-generated and what was not.

That means:

- Tagging AI-generated code in version control
- Retaining prompt and response logs for high-risk work
- Documenting human modifications that create authorship and accountability

## Practical Checklist

1. Use enterprise tiers of AI tools when you need indemnification and opt-outs.
2. Don't paste secrets, PII, or proprietary algorithms into prompts.
3. Run license compliance scanning in CI/CD.
4. Tag AI-generated code in version control with provenance metadata.
5. Require human review for all AI-generated code before merge.
6. Review cyber insurance for AI-code exclusions.
7. Document human modifications to establish copyriht.
8. Create an AI coding policy covering approved tools, data classification, and review requirements.

The legal landscape is evolving quickly. What is settled is that you are responsible for the code you ship. Much of the rest is still moving.
