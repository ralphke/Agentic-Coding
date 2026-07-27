# Proposal: Add Platform Fit to Lifecycle AI Engineering Guidance

**Change Slug:** `lifecycle-platform-fit`  
**Author:** Developer Agent  
**Date:** 2026-07-24  
**Status:** Accepted

## Problem Statement

The lifecycle-specific AI engineering reference is a catalogue of products but does
not identify their Azure, AWS, or GCP fit, the native alternative, or the cost of
adding a second toolchain. This can lead teams to buy overlapping tools without a
measurable capability gap.

## Goals

1. Add platform-native baselines for Azure, AWS, and GCP.
2. State when an external tool has a defensible incremental benefit.
3. Identify overlapping categories and recommend a primary-tool approach.
4. Clarify that GA and pricing must be verified per capability and commercial quote.
5. Correct known catalogue gaps and pricing-status caveats.

## Out of Scope

- Selecting a vendor for a specific organization.
- Procuring, configuring, or integrating any listed product.
- Replacing the lifecycle catalogue with a complete vendor comparison.

## Acceptance Criteria

- [ ] The reference includes Azure, AWS, and GCP native baseline guidance.
- [ ] The reference defines a cost-versus-benefit decision rule for external tools.
- [ ] The reference identifies overlapping tool categories and conditional specialist use.
- [ ] The reference adds Gemini Code Assist as the GCP-native development comparator.
- [ ] The reference qualifies product status and pricing assertions.

## Risk & Rollback

**Risk:** Platform product information and commercial pricing change frequently.

**Mitigation:** Date the review, link vendor documentation, and direct readers to
validate current feature availability and pricing before purchase.

**Rollback:** Revert the lifecycle reference and delete this in-flight change.