# MCP Migration Evidence

## Configuration

- Portable configuration is at `.mcp.json`.
- No credentials or input-prompt secrets are stored in the repository.
- `.mcp.json` does not declare `tools: ["*"]`.
- The security agent's customer-specific MCP placeholder no longer grants
  wildcard access. Its configured tool surface is limited to `mcp-server` and
  `mcp-security*`, pending replacement with the customer's actual hosted
  endpoint and authentication. The placeholder is not evidence of a working
  integration.
- The filesystem server is configured with `./openspec` rather than a Windows absolute path.

## Startup checks

- GitHub MCP endpoint: reachable; returned HTTP 401 without an OAuth access token.
- OpenSpec filesystem MCP: initialized successfully and restricted to `/workspaces/Agentic-Coding/openspec`.
- Azure MCP: launched successfully under `npx -y @azure/mcp@latest server start`.

## Copilot harness verification

- The active Copilot harness session discovered the configured OpenSpec filesystem tools.
- A filesystem read through `openspec-filesystem` returned the current change task file.
- The server allowed access only to `/workspaces/Agentic-Coding/openspec`.
- GitHub MCP OAuth was active: a tool call retrieved `ralphke/Agentic-Coding` pull request #20.
- The configured `npx` launcher resolved `@modelcontextprotocol/server-filesystem` 2.4.0 and `@azure/mcp` 4.0.0-beta.10.

These checks verify startup, discovery, authentication, and representative read-only tool calls in the target Copilot harness session.

## Customer-specific MCP compatibility boundary

The synchronized `v1.3.0` security agent contained a customer-specific
`custom-mcp` placeholder with unrestricted tools. The consumer project now
limits that placeholder to `mcp-server` and `mcp-security*`; it is retained for
future replacement with the centrally hosted customer endpoint and
authentication.

An upstream fix commit was prepared locally on
`fix/remove-local-security-mcp-fallback`, but publishing was blocked: git push
returned HTTP 403, and the GitHub API returned `Resource not accessible by
integration` when creating the remote branch. No upstream branch or pull request
was created. Because `.github/agents` is managed upstream, a future shared-asset
sync must preserve or resolve this consumer-specific placeholder deliberately;
it must not restore wildcard tool access.
