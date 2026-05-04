---
name: claude-harness
description: >
  Build, compose, and extend Claude Harness — a Nix-module-based Claude Code
  environment system. Use this skill whenever the user wants to: create a new
  harness profile, define module options for tools/MCP servers/sandboxing/system
  prompts, wire up a flake.nix entry point, compose profiles together, debug
  evalModules output, or understand how harness derivations are built. Also
  trigger for questions about hermetic Claude sessions, reproducible AI
  environments, per-project Claude configuration, or anything about pinning
  Claude's toolchain and context in Nix.
---

# Claude Harness Skill

A skill for building and composing Claude Code environments as Nix module derivations.

---

## Mental Model

The harness is a **pure function from Nix options to a Claude Code derivation**.

```
modules (profiles) → evalModules → config → mkHarness → /nix/store/…-claude-harness
```

Three layers:

1. **Module layer** — declares options (`claudeCode.tools.allowed`, `claudeCode.mcp.servers`, etc.)
2. **Profile layer** — sets options for a specific use case (`rust-dev`, `locked-review`, `default`)
3. **Derivation layer** — `mkHarness` calls `evalModules`, assembles the toolchain env, generates `CLAUDE.md` and `mcp.json`, and wraps everything in a `writeShellApplication`

---

## Module Schema

All options live under `claudeCode.*`:

```nix
claudeCode = {
  enable        # bool — enable the harness
  model         # str  — e.g. "claude-sonnet-4-20250514"

  tools = {
    allowed     # listOf str — tools Claude may use
    denied      # listOf str — tools explicitly blocked
  }

  toolchain = {
    packages    # listOf package — realized into hermetic PATH
  }

  environment   # attrsOf str — env vars injected into session

  systemPrompt  # lines — composable; use lib.mkAfter to append

  mcp.servers   # attrsOf mcpServerType — name → { command, args, env }

  sandbox = {
    enable        # bool
    allowNetwork  # bool (default false)
    writablePaths # listOf str (default ["/tmp"])
  }
}
```

**Key property**: `systemPrompt` is a `lines` option. Every imported profile can append with `lib.mkAfter`. The final prompt is the deterministic merge of all active modules — no manual concatenation.

---

## Profile Anatomy

A profile is a Nix module that sets `claudeCode.*` options:

```nix
# profiles/rust-dev.nix
{ config, lib, pkgs, ... }:
{
  claudeCode.toolchain.packages = [
    pkgs.rustc pkgs.cargo pkgs.rust-analyzer pkgs.clippy
  ];

  claudeCode.environment.RUST_BACKTRACE = "1";

  claudeCode.systemPrompt = lib.mkAfter ''
    You are working in a Rust project.
    Always run `cargo clippy` before marking tasks complete.
  '';

  claudeCode.mcp.servers.rust-docs = {
    command = "${pkgs.rust-mcp-server}/bin/rust-mcp-server";
    args = [];
  };
}
```

```nix
# profiles/locked-review.nix — read-only, sandboxed
{ ... }:
{
  claudeCode.tools.allowed  = [ "read" "grep" "glob" ];
  claudeCode.tools.denied   = [ "write" "bash" "edit" ];
  claudeCode.sandbox.enable = true;
  claudeCode.sandbox.allowNetwork = false;
}
```

Profiles compose via `imports`:

```nix
imports = [ ./profiles/rust-dev.nix ./profiles/locked-review.nix ];
```

Option merges are deterministic. Lists concatenate. `lines` options respect `mkBefore`/`mkAfter` priority.

---

## mkHarness — The Derivation Builder

```nix
# lib/mkHarness.nix
{ nixpkgs, modules }:
let
  eval = nixpkgs.lib.evalModules {
    modules = [ ./modules/default.nix ] ++ modules;
  };
  cfg = eval.config.claudeCode;

  toolchainEnv = nixpkgs.buildEnv {
    name = "claude-toolchain";
    paths = cfg.toolchain.packages;
  };

  claudeMd  = nixpkgs.writeText "CLAUDE.md"  cfg.systemPrompt;
  mcpConfig = nixpkgs.writeText "mcp.json"   (builtins.toJSON { mcpServers = cfg.mcp.servers; });

in nixpkgs.writeShellApplication {
  name = "claude-harness";
  runtimeInputs = cfg.toolchain.packages ++ [ nixpkgs.claude-code ];
  text = ''
    export PATH="${toolchainEnv}/bin:$PATH"
    exec claude \
      --model ${cfg.model} \
      --mcp-config ${mcpConfig} \
      --system-prompt-file ${claudeMd} \
      "$@"
  '';
}
```

**Nothing is downloaded at runtime.** Everything — toolchain paths, MCP server binaries, the assembled system prompt — is in the Nix store before `claude` is exec'd.

---

## Flake Entry Point

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    mkHarness = import ./lib/mkHarness.nix { inherit nixpkgs; };
  in {
    packages.x86_64-linux = {
      default = mkHarness { modules = [ ./profiles/default.nix ]; };
      rust    = mkHarness { modules = [ ./profiles/rust-dev.nix ]; };
      review  = mkHarness { modules = [ ./profiles/locked-review.nix ]; };
    };

    # Re-exported for downstream projects to call
    lib.mkHarness = mkHarness;
  };
}
```

Usage:
```bash
nix run .#rust                            # Rust dev session
nix run .#review                          # Locked review session
nix run github:myorg/claude-harness#rust  # Pinned remote session
```

---

## Per-Project Override Pattern

A project's own `flake.nix` imports the org harness and overrides only what differs:

```nix
inputs.claude-harness.url = "github:myorg/claude-harness";

outputs = { self, nixpkgs, claude-harness }:
{
  packages.x86_64-linux.claude =
    claude-harness.lib.mkHarness {
      modules = [
        claude-harness.profiles.rust          # inherit org standard
        {
          # project-specific overrides
          claudeCode.systemPrompt = lib.mkAfter ''
            This project uses diesel for database access.
          '';
        }
      ];
    };
}
```

---

## Common Tasks

**Add a new tool to the toolchain**
```nix
claudeCode.toolchain.packages = [ pkgs.jq pkgs.ripgrep ];
```

**Append to the system prompt without clobbering other modules**
```nix
claudeCode.systemPrompt = lib.mkAfter "Your addition here.";
```

**Add an MCP server**
```nix
claudeCode.mcp.servers.myserver = {
  command = "${pkgs.my-mcp}/bin/my-mcp";
  args = [ "--port" "3000" ];
  env = { MY_TOKEN = "$MY_TOKEN"; };
};
```

**Enable sandbox with network access**
```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = true;
  writablePaths = [ "/tmp" "./src" ];
};
```

---

## Reference Files

- `references/module-options.md` — full option type definitions and defaults
- `references/sandbox.md` — bubblewrap/nsjail wrapper implementation
- `references/mcp-server-type.md` — mcpServerType submodule schema
- `agents/profile-generator.md` — agent for generating profiles from natural language descriptions
