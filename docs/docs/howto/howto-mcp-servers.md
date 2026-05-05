---
sidebar_position: 4
title: Configure MCP Servers
description: Set up Model Context Protocol servers for enhanced capabilities
---

# How to Configure MCP Servers

## Goal

Add MCP (Model Context Protocol) servers to your Yuki profile to extend the agent's capabilities.

## When to Use This Guide

- You need access to external tools or services
- You want to integrate with specific APIs or databases
- You need specialized capabilities (file watching, database access, etc.)

## What is MCP?

MCP (Model Context Protocol) is a standard for connecting AI models to external tools and services. Yuki can start MCP servers as part of the session - they're resolved to Nix store paths at build time, not downloaded at runtime.

> **NOTE**: Unlike other setups that download MCP servers when you start the agent, Yuki resolves them during `nix build`. This ensures reproducibility - the same server binary version is used every time.

## Step 1: Understand MCP Configuration

MCP servers are configured in your profile as an attribute set:

```nix
claudeCode.mcp.servers = {
  # Key is the server name (used in logs/debugging)
  "server-name" = {
    # command - path to the executable (must be in nix store)
    command = "${pkgs.serverPackage}/bin/server";
    # args - command line arguments
    args    = [ "--flag" "value" ];
    # env - environment variables for the server
    env     = { ENV_VAR = "value"; };
  };
};
```

**Key points:**
- `command` must be a path in the Nix store (starts with `/nix/store/`)
- Use `${pkgs.package}/bin/name` to reference packaged executables
- `args` is a list of strings passed to the command
- `env` is an attribute set of environment variables

> **NOTE**: The `${...}` syntax is Nix string interpolation - it inserts the package's store path into the string.

## Example: Filesystem Server

```nix
claudeCode.mcp.servers.filesystem = {
  command = "${pkgs.nodejs}/bin/node";
  args = [
    "${pkgs.mcp-filesystem}/bin/mcp-filesystem-server"
    "--allowed-directory"
    "/workspace"
  ];
  env = { };
};
```

**How it works:**
1. `${pkgs.nodejs}/bin/node` - Path to Node.js runtime from Nix
2. `${pkgs.mcp-filesystem}/bin/mcp-filesystem-server` - Path to the MCP server
3. The arguments configure what directory the server can access

> **NOTE**: The MCP server binary itself is from a Nix package - it's already in the store when you build.

## Example: Database Server

```nix
claudeCode.mcp.servers.database = {
  command = "${pkgs.mcp-db}/bin/mcp-db";
  args = [ "--connection" "postgresql://localhost/dev" ];
  env = {
    DB_PASSWORD = "secret";  # Be careful with secrets
  };
};
```

**Security note:**
- Environment variables set here are visible to the MCP server process
- Don't hardcode secrets - use environment variables from the shell

## Example: Custom HTTP Server

```nix
claudeCode.mcp.servers.custom = {
  command = "python";
  args = [ "-m" "my_mcp_server" ];
  env = {
    MCP_SERVER_URL = "http://localhost:8080";
  };
};
```

You can also use system executables (like `python`) - Nix will find them in PATH.

## Step 2: Build and Verify

```bash
# Build profile with MCP servers
nix build .#default

# Check generated config
cat ~/.yuki/settings.json

# Verify servers load
./result/bin/yuki doctor
```

**What happens during build:**
1. Nix evaluates your module
2. Resolves `${pkgs.*}` to actual store paths
3. Generates a settings.json with MCP config
4. Creates the startup script that launches servers

> **NOTE**: The MCP configuration goes to `~/.yuki/settings.json` which the yuki CLI reads at startup.

## Security Considerations

### Environment Variables

Never hardcode secrets in your profile:

```nix
# BAD - secrets in plain text
env = { API_KEY = "secret123"; };

# GOOD - reference from environment
env = { API_KEY = "$API_KEY"; };  # Set at runtime
```

### Using envFile for Secrets

```nix
# In your profile - reference a .env file
claudeCode.envFile = ./secrets.env;

# secrets.env (add to .gitignore!)
ANTHROPIC_API_KEY=sk-ant-...
DB_PASSWORD=secret
```

The `.env` file is sourced when the session starts, and its variables are available to MCP servers.

> **NOTE**: The `envFile` option uses `set -a` in bash to export all variables - this makes them available to child processes including MCP servers.

## Available MCP Servers

Common MCP servers available as Nix packages (search `nix search nixpkgs mcp`):

| Server | Purpose |
|--------|---------|
| `mcp-filesystem` | File system access with permissions |
| `mcp-database` | Database queries (PostgreSQL, MySQL) |
| `mcp-git` | Git operations |
| `mcp-github` | GitHub API integration |
| `mcp-slack` | Slack integration |

> **NOTE**: Not all MCP servers are available in nixpkgs. Some may need to be packaged or used via `inputs` in your flake.

## Troubleshooting

### Server Not Found

```bash
# Check if package exists in nixpkgs
nix search nixpkgs mcp-filesystem
```

### Connection Issues

```bash
# Verify server starts
./result/bin/yuki mcp
```

The `mcp` command shows configured servers and their status.

### Permission Denied

Check the command path exists:
```nix
command = "${pkgs.mcp-server}/bin/mcp-server";
# Verify the path exists
ls -la $(nix eval --raw pkgs.mcp-server.bin.mcp-server 2>/dev/null)
```

> **NOTE**: Use `nix eval --raw` to get just the store path without quotes - useful for scripting.

## See Also

- [Reference: Module Options](../reference/reference-options.md)
- [How-to: Create Profile](howto-create-profile.md)