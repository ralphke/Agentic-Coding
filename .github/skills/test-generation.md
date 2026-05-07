# Skill: Test Generation from Spec Scenarios

**Persona:** QA Engineer Agent  
**Input:** `spec.md` scenarios + source code from Developer Agent  
**Output:** Test suites with ≥ 80% coverage on new code

---

## When to Use This Skill

Use when a PR is labelled `stage:test` by the Developer Agent.

---

## Execution Steps

1. **Read spec scenarios** — Open `spec/openspec/changes/<slug>/specs/<domain>/spec.md`
2. **List all scenarios** — Enumerate every Given/When/Then block
3. **Inspect source code** — Understand the implementation to determine test levels
4. **Plan test coverage** — Map scenarios to test level (unit/integration/e2e)
5. **Write tests** — One test function per scenario using project test framework
6. **Add edge cases** — Add boundary tests for numeric limits, empty inputs, large inputs
7. **Mock externals** — Mock all HTTP calls, database queries, file I/O
8. **Run tests** — Execute test suite and capture coverage report
9. **Fill gaps** — Add targeted tests for uncovered lines (≥ 80% required)
10. **Label PR** — Apply `stage:security` when coverage gate passes

---

## Test Naming Convention

```
test_<subject>_<condition>_<expected_outcome>

# Python examples:
test_export_service_with_valid_user_returns_csv_response
test_export_service_with_unknown_user_raises_not_found_error
test_export_service_with_empty_dataset_returns_empty_csv

# .NET examples:
ExportToCsv_WithValidUser_ReturnsCsvContent
ExportToCsv_WithUnknownUser_ThrowsUserNotFoundException
ExportToCsv_WithEmptyDataset_ReturnsEmptyCsv
```

---

## Test Level Decision Matrix

| Code Type                          | Unit | Integration | E2E |
|------------------------------------|------|-------------|-----|
| Pure function / utility            | ✅   |             |     |
| Service with injected dependencies | ✅   | ✅          |     |
| API endpoint handler               |      | ✅          |     |
| User-facing workflow               |      |             | ✅  |
| Database query                     |      | ✅          |     |
| Auth/authorization logic           | ✅   | ✅          |     |

---

## Quality Checks

- [ ] ≥ 1 test per Given/When/Then scenario
- [ ] All unhappy paths have negative tests
- [ ] All external dependencies are mocked in unit tests
- [ ] Coverage report shows ≥ 80% for new code
- [ ] Test names describe the scenario without reading the body
- [ ] No `time.sleep()` or wall-clock dependencies
- [ ] Tests pass deterministically (run 3x to verify)
- [ ] Tests run in < 30s for unit suite, < 5min for integration suite
