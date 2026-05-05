---
sidebar_position: 1
slug: /
title: Introduction
description: Reproducible Agent Sessions for AI Engineering Teams
---

# Yuki - Reproducible Agent Sessions for AI Engineering Teams

## The Problem: "Works on My Machine" for AI Agents

Modern AI coding agents like Claude Code are powerful, but their deployment suffers from a fundamental reproducibility crisis:

| Source of Irreproducibility | What Goes Wrong |
|-----------------------------|------------------|
| **Tool versions** | Developer has Rust 1.80, CI has 1.75 - different clippy warnings |
| **System prompts** | One developer edited CLAUDE.md, another did not - different behavior |
| **MCP servers** | Server downloads deps at runtime - inconsistent across machines |
| **Environment variables** | Machine-specific exports - secrets leaked or missing |
| **Tool permissions** | Set interactively, not declared - audit nightmare |

## The Yuki Solution: Agent Sessions as Build Artifacts

Yuki treats the agent session as a pure function from Nix module configuration to content-addressed derivation:

```
profiles -> evalModules -> mkHarness -> /nix/store/...-yuki
```

Everything the agent needs is resolved at build time, before the agent ever starts:

- **Model selection** - pinned to specific model version
- **Tool permissions** - explicit allowlist/denylist
- **Toolchain** - hermetic PATH from Nix packages
- **Environment variables** - declared, not assumed
- **System prompt** - composable from modules
- **MCP servers** - resolved to Nix store paths
- **Sandbox policy** - network/filesystem restrictions

## Key Features

### Declarative, Not Imperative

You do not tell Yuki what to do at runtime. You declare what the session is:

```nix
claudeCode = {
  model = "claude-sonnet-4-6";
  tools.allowed = [ "bash" "read" "write" "edit" "grep" "glob" ];
  toolchain.packages = [ pkgs.rustc pkgs.clippy pkgs.cargo ];
  sandbox.enable = true;
  sandbox.allowNetwork = false;
};
```

### Hermetic by Default

The sandbox is a module option, not a runtime flag:

```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = false;
  writablePaths = [ "/tmp" ];
};
```

### Profile Composition

Profiles are Nix modules that compose deterministically:

```nix
imports = [
  ./profiles/rust-dev.nix
  ./profiles/security-review.nix
];
```

## Quick Start

```bash
# Clone and build
git clone https://github.com/Spirizeon/yuki-code
cd yuki-code
nix build .#default

# Run the hermetic session
./result/bin/yuki
```

## Ready-Made Profiles

| Profile | Use Case |
|---------|----------|
| default | Base tools + REPL |
| rust | Rust development with toolchain |
| review | Read-only, sandboxed code review |

## Documentation

- [Core Philosophy](./docs/soul.md) - Design values
- [Module System](./docs/skill.md) - Profile authoring
- [CLI Reference](./docs/usage.md) - Usage examples
- [Development Guide](./DEV.md) - Contributor guide

## Credits

Built on [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code).