# Upstream Synchronization Evidence

## Target

- Source: `ralphke/agentic-shared`
- Previous pin: `v1.2.1`
- Applied pin: `v1.3.0`
- Manifest validation: passed

## Synchronization method

The script preview correctly detected managed-file conflicts. The conflict set was reconciled to upstream `v1.3.0`, and the asset trees were synchronized while preserving protected `local/` paths.

## Changed managed assets

- 10 custom-agent files
- 3 OpenSpec command skills and the shared skills updated by the upstream tree
- Shared instructions
- Shared workflows and issue templates
- `.agentic-shared.yml`

## Post-sync duplicate skill review

The following pairs now differ and neither file is removed:

- `deploy-pipeline`
- `idea-to-spec`
- `legal-compliance-review`
- `pr-review`
- `security-review`
- `spec-to-design`
- `test-generation`
- `workflow-retrospective`

Canonical content and duplicate ownership require manual review.
