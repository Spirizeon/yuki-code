---
sidebar_position: 4
title: Module System
description: Building and composing Yuki harness configurations
---

# Module System

A skill for building and composing declarative Claude Code environments as Nix module derivations.

## Mental Model

The harness is a **pure function from Nix options to a Claude Code derivation**.

```
profiles (modules) -> evalModules -> config -> buildEnv -> mkHarness -> /nix/store/...-yuki
```

Three layers:

1. **Module layer** (`modules/default.nix`) - declares the `claudeCode.*` option schema
2. **Profile layer** (`profiles/*.nix`) - sets options for a specific use case
3. **Derivation layer** (`lib/mkHarness.nix`) - realizes profiles into a runnable harness

## Option Schema

All options live under `claudeCode.*`:

```nix
claudeCode = {
  # Core
  enable        # bool - enable the harness (default: true)
  model        # string - model name e.g. "claude-sonnet-4-6"
  
  # Tools
  tools = {
    allowed    # listOf string - tools Claude may use
    denied     # listOf string - tools explicitly blocked
  };
  
  # Toolchain
  toolchain = {
    packages   # listOf package - realized into hermetic PATH
  };
  
  # Environment
  environment   # attrsOf string - env vars injected into session
  envFile         # path - .env file to source
  
  # System Prompt (composable)
  systemPrompt   # lines - use lib.mkAfter to append
  
  # MCP Servers
  mcp.servers."name" = {
    command     # string - path to MCP server binary
    args        # listOf string - CLI args
    env         # attrsOf string - env vars
  };
  
  # Sandbox (hermetic isolation)
  sandbox = {
    enable       # bool - enable sandbox
    allowNetwork # bool - allow network (default: false)
    writablePaths # listOf string - writable paths (default: ["/tmp"])
  };
};
```

## Profile Example

```nix
# profiles/rust-dev.nix
{ config, lib, pkgs, ... }:
{
  claudeCode.model = "claude-sonnet-4-6";
  
  claudeCode.toolchain.packages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.rust-analyzer
    pkgs.clippy
  ];
  
  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    RUSTDOC_HTML_FRONTEND_URL = "https://doc.rust-lang.org/std";
  };
  
  claudeCode.systemPrompt = lib.mkAfter ''
    You are working in a Rust project.
    Always run `cargo clippy` before marking tasks complete.
    Run `cargo test` to verify tests pass.
  '';
  
  # MCP server for Rust docs
  claudeCode.mcp.servers.rust-docs = {
    command = "${pkgs.rust-mcp-server}/bin/rust-mcp-server";
    args = [];
    env = {};
  };
}
```

```nix
# profiles/locked-review.nix - read-only, sandboxed
{ ... }:
{
  claudeCode.tools.allowed = [ "read" "grep" "glob" ];
  claudeCode.tools.denied  = [ "write" "bash" "edit" ];
  
  claudeCode.sandbox = {
    enable = true;
    allowNetwork = false;
    writablePaths = [];
  };
}
```

## mkHarness - Derivation Builder

```nix
# lib/mkHarness.nix
{ pkgs, modules, modulePath }:

let
  eval = pkgs.lib.evalModules {
    modules = [ "${modulePath}/default.nix" ] ++ modules;
    specialArgs = { inherit pkgs; };
  };
  
  cfg = eval.config.claudeCode;
  
  toolchainEnv = pkgs.buildEnv {
    name = "yuki-toolchain";
    paths = cfg.toolchain.packages;
  };
  
  toolsAllowedStr = builtins.concatStringsSep "," cfg.tools.allowed;
  modelStr = cfg.model;
  shellPath = pkgs.stdenv.shell;
  envFileVal = if cfg.envFile != null then toString cfg.envFile else "";

in

pkgs.writeScriptBin "yuki" (
  "#!" + shellPath + "\n" +
  "set -e\n" +
  "export PATH=\"${toolchainEnv}/bin:$PATH\"\n" +
  "export CLAUDE_TOOLS=\"${toolsAllowedStr}\"\n" +
  
  # Load .env if configured
  "if [ -n \"${envFileVal}\" ] && [ -f \"${envFileVal}\" ]; then\n" +
  "  set -a\n" +
  "  source \"${envFileVal}\"\n" +
  "  set +a\n" +
  "fi\n" +
  
  "MODEL=\"${modelStr}\"\n" +
  "exec yuki --model \"$MODEL\" \"$@\"\n"
)
```

**Key property:** Nothing is downloaded at runtime. Toolchain, MCP binaries, and the system prompt are all in the Nix store before `yuki` starts.

## Flake Entry Point

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

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
      default = mkHarness [ ./profiles/default.nix ];
      rust    = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
      review = mkHarness [ ./profiles/default.nix ./profiles/locked-review.nix ];
    };

    apps.x86_64-linux = {
      default = flake-utils.lib.mkApp {
        drv = mkHarness [ ./profiles/default.nix ];
        exePath = "/bin/yuki";
      };
      rust = flake-utils.lib.mkApp {
        drv = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
        exePath = "/bin/yuki";
      };
    };
    
    lib.mkHarness = mkHarness;
  };
}
```

## Usage Patterns

### Run a Profile

```bash
nix run .#default        # Base session
nix run .#rust         # Rust development
nix run .#review       # Locked review
```

### Run Remote

```bash
nix run github:spirizeon/yuki#rust
```

### Per-Project Override

```nix
# myproject/flake.nix
{
  inputs.yuki.url = "github:spirizeon/yuki";

  outputs = { self, yuki, ... }:
  {
    packages.default = yuki.lib.mkHarness {
      modules = [
        yuki.profiles.rust
        {
          claudeCode.systemPrompt = lib.mkAfter ''
            This project uses diesel for database access.
          '';
        }
      ];
    };
  };
}
```

## Common Tasks

### Add Tool to Toolchain

```nix
claudeCode.toolchain.packages = [ pkgs.jq pkgs.ripgrep ];
```

### Append to System Prompt

```nix
claudeCode.systemPrompt = lib.mkAfter "Your addition here.";
```

### Add MCP Server

```nix
claudeCode.mcp.servers.myserver = {
  command = "${pkgs.my-mcp}/bin/my-mcp";
  args = [ "--port" "3000" ];
  env = { MY_TOKEN = "$MY_TOKEN"; };
};
```

### Configure Sandbox

```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = true;
  writablePaths = [ "/tmp" "./src" ];
};
```

### Set Environment

```nix
claudeCode.environment = {
  RUST_BACKTRACE = "1";
  CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
};
```

## Debugging evalModules

```bash
# See the merged config
nix eval .#lib.mkHarness.out
nix eval .#lib.mkHarness --apply 'x: x' | jq

# Check the system prompt
nix build .#default --show-trace
cat result/lib/CLAUDE.md

# See toolchain packages
nix eval .#default.toolchain.packages --apply 'builtins.attrNames x'
```

## Reference

- `modules/default.nix` - Option schema (the source of truth)
- `lib/mkHarness.nix` - Derivation builder
- `flake.nix` - Flake entry point
- `profiles/*.nix` - Profile compositions