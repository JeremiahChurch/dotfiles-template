# Global Claude Code Instructions

## Environment
- Always running inside WSL. When your response will include file paths, URLs/hostnames, or SSH commands, invoke the `wsl-interop` skill and follow its output formatting rules. This applies every time — not just when the user mentions WSL or paths.

## MCP Server Management
MCP servers are managed by MCP Wrangler via mcp-sync. Do not edit .mcp.json manually.
Use mcp-sync commands: list, add <name>, remove <name>, server add/remove/start/stop.
Run "mcp-sync list" to see available servers. Run "mcp-sync" to sync new servers.
