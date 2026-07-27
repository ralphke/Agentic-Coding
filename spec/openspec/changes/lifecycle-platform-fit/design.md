# Design: Add Platform Fit to Lifecycle AI Engineering Guidance

## Approach

Preserve the existing lifecycle catalogue and add a decision-oriented section before
it. The section establishes a native baseline for each hyperscaler, a common rule for
adding third-party tools, and category-specific overlap guidance. A GCP-native
development entry completes the asymmetric development table.

## Content Decisions

- Treat GitHub Copilot as source-control-platform aligned rather than cloud-runtime
  specific.
- Treat Amazon Q Developer and Gemini Code Assist as conditional AWS and GCP
  accelerators, respectively, rather than universal coding-assistant defaults.
- Treat Azure AI Foundry, Azure Pipelines, Defender for Cloud DevOps security, and
  Application Insights as the Azure baseline for agent engineering, delivery,
  security, and observability.
- Recommend external tools only for a demonstrated specialist gap, such as
  repository-scale context, Java coverage remediation, visual regression testing, or
  production agent configuration control.
- Mark availability and prices as vendor assertions that require per-capability and
  commercial validation.

## Validation

1. Confirm all Markdown links in the updated document use valid URL syntax.
2. Verify the document includes all stated acceptance-criteria concepts.
3. Review the diff to ensure existing catalogue rows remain focused and unrelated
   workshop content is unchanged.