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

## Step 1: Understand MCP Configuration

MCP servers are configured in your profile:

```nix
claudeCode.mcp.servers = {
  "server-name" = {
    command = "${pkgs.serverPackage}/bin/server";
    args    = [ "--flag" "value" ];
    env     = { ENV_VAR = "value"; };
  };
};
```

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

## Step 2: Build and Verify

```bash
# Build profile with MCP
nix build .#default

# Check generated config
cat ~/.yuki/settings.json

# Verify servers load
./result/bin/yuki doctor
```

## Security Considerations

### Environment Variables

Never hardcode secrets in your profile:

```nix
# BAD - secrets in plain text
env = { API_KEY = "secret123"; };

# GOOD - use environment variables
env = { API_KEY = "$API_KEY"; };  # Set at runtime
```

### Using envFile for Secrets

```nix
# In your profile
claudeCode.envFile = ./secrets.env;

# secrets.env (add to .gitignore!)
ANTHROPIC_API_KEY=sk-ant-...
DB_PASSWORD=secret
```

## Available MCP Servers

Common MCP servers available as Nix packages:

| Server | Purpose |
|--------|---------|
| `mcp-filesystem` | File system access |
| `mcp-database` | Database queries |
| `mcp-git` | Git operations |
| `mcp-github` | GitHub API integration |
| `mcp-slack` | Slack integration |

## Troubleshooting

### Server Not Found

```bash
# Check if package exists
nix search nixpkgs mcp-filesystem
```

### Connection Issues

```bash
# Verify server starts
./result/bin/yuki mcp
```

### Permission Denied

Check the command path exists:
```nix
command = "${pkgs.mcp-server}/bin/mcp-server";
# Make sure this path exists
ls -la $(nix eval --raw pkgs.mcp-server/bin.mcp-server)
```

## See Also

- [Reference: Module Options](../reference/reference-options.md)
- [How-to: Create Profile](howto-create-profile.md)