# Delta for sdlc-process

## ADDED Requirements

### Requirement: Lifecycle Platform Capability Guidance
The lifecycle engineering reference MUST compare GitHub, GitLab, and Atlassian
across Define & plan, Develop & build, Test & validate, Release & deploy,
Monitor & secure, and Optimize & improve. Each phase MUST identify the
specialist capability that native platform coverage does not replace.

#### Scenario: Reader compares a lifecycle phase
- GIVEN a reader is evaluating a lifecycle phase
- WHEN they consult the platform capability matrix
- THEN GitHub, GitLab, and Atlassian capabilities are shown for that phase
- AND relevant differentiated specialist products are identified

#### Scenario: Reader evaluates platform tradeoffs
- GIVEN a reader is considering one of the three platforms
- WHEN they consult the comparative SWOT analysis
- THEN they can assess its strengths, weaknesses, opportunities, and threats
- AND the analysis names the specialist products that justify a pilot

#### Scenario: Vendor capability changes
- GIVEN platform capabilities, plans, or deployment support can change
- WHEN the reference presents a capability comparison
- THEN claims link to vendor documentation
- AND the reference tells readers to validate availability before adoption
