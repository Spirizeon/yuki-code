---
sidebar_position: 4
title: Module System
description: Building and composing Yuki harness configurations for production teams
---

# Module System

The complete guide to building declarative Claude Code environments with Yuki.

## Architecture Overview

Yuki has three layers:

```
┌─────────────────────────────────────────────────────────────────┐
│  Profile Layer (profiles/*.nix)                                 │
│  - Sets options for specific use cases                          │
│  - Composable via imports                                        │
├─────────────────────────────────────────────────────────────────┤
│  Module Layer (modules/default.nix)                             │
│  - Declares claudeCode.* option schema                          │
│  - Type definitions and defaults                                │
├─────────────────────────────────────────────────────────────────┤
│  Derivation Layer (lib/mkHarness.nix)                           │
│  - Realizes profiles into runnable binary                       │
│  - Generates shell script in Nix store                          │
└─────────────────────────────────────────────────────────────────┘
```

## Complete Option Schema

```nix
claudeCode = {
  # === Core ===
  enable        = true;                    # Enable harness
  model         = "claude-sonnet-4-6";    # Model name/alias
  
  # === Tool Permissions ===
  tools = {
    allowed     = [ "bash" "read" "write" "edit" "grep" "glob" "websearch" "webfetch" "agent" "todo" ];
    denied      = [ ];                     # Tools blocked from allowed
  };
  
  # === Hermetic Toolchain ===
  toolchain = {
    packages = [                         # Packages in PATH
      pkgs.rustc
      pkgs.cargo
      pkgs.clippy
    ];
  };
  
  # === Environment Variables ===
  environment = {                        # Injected into session
    RUST_BACKTRACE = "1";
  };
  envFile         = ./secrets.env;       # Optional .env file
  
  # === System Prompt (Composable) ===
  systemPrompt = ''                      # Base prompt
    lib.mkAfter ''                      # Appended via mkAfter
      Your additions here.
    '';
  
  # === MCP Servers ===
  mcp.servers = {
    "server-name" = {
      command = "${pkgs.mcpServer}/bin/mcp-server";
      args    = [ "--port" "3000" ];
      env     = { API_KEY = "..."; };
    };
  };
  
  # === Sandbox (Hermetic Isolation) ===
  sandbox = {
    enable         = true;
    allowNetwork   = false;              # Default: no network
    writablePaths  = [ "/tmp" ];         # Explicitly writable dirs
  };
};
```

## Production Profile Examples

### Backend Development Profile

```nix
# profiles/backend-dev.nix
{ config, lib, pkgs, ... }:

{
  claudeCode.model = "claude-sonnet-4-6";
  
  # Full toolchain for backend development
  claudeCode.toolchain.packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    diesel-cli
    sqlx-cli
    postgresql
    redis
  ];
  
  # Environment for backend work
  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    RUST_LOG = "debug";
    DATABASE_URL = "postgresql://localhost/dev";
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
  };
  
  # Backend-specific system prompt
  claudeCode.systemPrompt = lib.mkAfter ''
    You are working on a backend service.
    - Always run 'cargo clippy --allow-dirty' before marking complete
    - Run 'cargo test' to verify all tests pass
    - Check database migrations with 'diesel migration revert'
    - Verify SQL with 'sqlx prepare' before committing
  '';
}
```

### Security Review Profile

```nix
# profiles/security-review.nix
{ ... }:

{
  # Restricted toolset - read only
  claudeCode.tools.allowed = [ "read" "grep" "glob" "websearch" ];
  claudeCode.tools.denied = [ "write" "edit" "bash" "execute" "agent" ];
  
  # Strict sandbox - no network, no writes
  claudeCode.sandbox = {
    enable = true;
    allowNetwork = false;
    writablePaths = [ ];
  };
  
  # Security-focused system prompt
  claudeCode.systemPrompt = lib.mkAfter ''
    You are performing a security review.
    - Never modify any files
    - Use grep and glob to find vulnerabilities
    - Focus on: SQL injection, XSS, auth bypass, secrets exposure
    - Report findings, do not suggest fixes
  '';
}
```

### Data Science Profile

```nix
# profiles/data-science.nix
{ config, lib, pkgs, ... }:

{
  claudeCode.model = "claude-sonnet-4-6";
  
  claudeCode.toolchain.packages = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.venv
    python311Packages pandas
    python311Packages numpy
    python311Packages scikit-learn
    python311Packages jupyter
    R
    rPackages.tidyverse
  ];
  
  claudeCode.environment = {
    PYTHONPATH = "/home/user/packages";
    JUPYTER_CONFIG_DIR = "/home/user/.jupyter";
  };
  
  claudeCode.systemPrompt = lib.mkAfter ''
    You are working in a data science environment.
    - Use pandas and numpy for data manipulation
    - Prefer sklearn for ML tasks
    - Document code in notebooks
  '';
  
  claudeCode.sandbox = {
    enable = true;
    allowNetwork = true;  # Data science often needs network
    writablePaths = [ "/tmp" "./data" "./notebooks" ];
  };
}
```

## Composing Multiple Profiles

The power of Yuki is composition - combine profiles:

```nix
# flake.nix
{
  outputs = { self, nixpkgs, flake-utils }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    mkHarness = modules:
      import ./lib/mkHarness.nix {
        inherit pkgs modules;
        modulePath = ./modules;
      };
  in
  {
    packages.x86_64-linux = {
      # Composition: base + backend + monitoring-tools
      backend = mkHarness [
        ./profiles/default.nix
        ./profiles/backend-dev.nix
        ./profiles/monitoring.nix
      ];
      
      # Composition: base + security
      secure-review = mkHarness [
        ./profiles/default.nix
        ./profiles/security-review.nix
      ];
      
      # Full data science stack
      data-science = mkHarness [
        ./profiles/default.nix
        ./profiles/data-science.nix
      ];
    };
  };
}
```

## MCP Server Configuration

### Stdio MCP Server

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

### HTTP/SSE MCP Server

```nix
claudeCode.mcp.servers.custom = {
  command = "python";
  args = [ "-m" "mcp_server" ];
  env = {
    MCP_SERVER_URL = "http://localhost:8080";
    API_KEY = "secret";  # Be careful with secrets
  };
};
```

## Environment Variable Security

### Using envFile for Secrets

```nix
# profiles/production.nix
{
  claudeCode.envFile = ./secrets.env;  # Add to .gitignore!
}
```

```bash
# secrets.env (DO NOT COMMIT)
ANTHROPIC_API_KEY=sk-ant-...
DATABASE_URL=postgresql://...
```

### Restricting Environment Variables

```nix
claudeCode.environment = {
  # Safe variables only
  RUST_BACKTRACE = "1";
  LOG_LEVEL = "info";
  
  # DO NOT include secrets - use envFile instead
};
```

## Sandbox Configuration by Use Case

| Use Case | enable | allowNetwork | writablePaths |
|----------|--------|--------------|----------------|
| Read-only review | true | false | [] |
| Development | true | true | ["/tmp", "./src"] |
| CI automation | true | false | ["/tmp"] |
| Interactive | false | true | ["/tmp"] |

## Debugging and Verification

### Inspect Merged Configuration

```bash
# See full merged config
nix eval .#lib.mkHarness.out

# See specific options
nix eval .#lib.mkHarness --apply 'x: x.claudeCode.model'
nix eval .#lib.mkHarness --apply 'x: x.claudeCode.toolchain.packages'
```

### Verify the Derivation

```bash
# Build and inspect
nix build .#default --show-trace

# Check generated files in result
ls -la result/bin/
cat result/bin/yuki

# Verify system prompt
cat result/lib/CLAUDE.md 2>/dev/null || echo "No CLAUDE.md"
```

### Test in CI

```yaml
# .github/workflows/yuki-test.yml
steps:
  - uses: actions/checkout@v4
  - uses: cachix/install-nix-action@v27
    with:
      extra_nix_config: flakes = true
  - run: nix build .#default
  - run: ./result/bin/yuki --version
  - run: ./result/bin/yuki doctor
```

## Best Practices for Production Teams

1. **Pin versions** - Use specific nixpkgs revision in flake.lock
2. **Separate secrets** - Use envFile, never commit secrets
3. **Audit trail** - Store the Nix store path with session logs
4. **CI parity** - Run same profile in CI as local dev
5. **Profile inheritance** - Compose from base profiles
6. **Version control** - Profile changes go through PR review

## Reference

| File | Purpose |
|------|---------|
| `modules/default.nix` | Option schema (source of truth) |
| `lib/mkHarness.nix` | Derivation builder |
| `flake.nix` | Flake entry point |
| `profiles/*.nix` | Profile compositions |