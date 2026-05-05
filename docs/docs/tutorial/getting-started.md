---
sidebar_position: 1
title: Getting Started
description: Learn what Yuki is and why it matters for your team
---

# Getting Started with Yuki

## What You Will Learn

By the end of this tutorial, you will understand:
- What Yuki does and why it exists
- The core problem Yuki solves
- How Yuki fits into your development workflow

## What is Yuki?

Yuki is a **declarative harness for Claude Code** that treats agent sessions as build artifacts.

In plain English: Yuki lets you define what your AI agent should have access to (tools, permissions, environment, MCP servers) in configuration files—and then builds a reproducible environment from those definitions.

## The Problem Yuki Solves

Imagine this scenario:

> **Developer A**: "It works on my machine!"
> **Developer B**: "But it fails in CI..."
> **Developer C**: "I don't have Rust installed, what do I need?"

This is the "works on my machine" problem, but for AI coding agents. Without Yuki:

- Each developer has different tools installed
- System prompts drift over time
- MCP servers download dependencies at runtime
- No audit trail of what the agent could do

Yuki solves this by making your agent environment **declarative** and **reproducible**.

## How Yuki Works

```
Your Configuration (Nix modules)
        ↓
    nix build
        ↓
/nix/store/...yuki (Reproducible derivation)
        ↓
   Claude Code Session
```

**Explanation:**
1. **Nix modules** - Declarative configuration files that define your agent's settings
2. **nix build** - The Nix build system that evaluates your modules and creates a derivation
3. **/nix/store/...yuki** - A content-addressed path in the Nix store containing your built environment
4. **Claude Code Session** - The actual agent running with your predefined configuration

> **Nix Terminology**: The *Nix store* (`/nix/store/`) is where Nix stores all build outputs. Each path is content-addressed (hash-based), meaning the same inputs always produce the same path. This is what makes reproducibility possible.

## Key Concepts

### 1. Profiles

A profile is a collection of settings that define an agent session:

```nix
# A simple profile - defines WHAT the session is, not WHAT to do
{ lib, pkgs, ... }: {
  claudeCode.model = "sonnet";           # Which AI model to use
  claudeCode.tools.allowed = [ "read" "grep" "glob" ];  # Tools permitted
}
```

**Explanation:**
- `{ lib, pkgs, ... }:` - The Nix function arguments. `lib` provides helper functions (like `mkAfter`), `pkgs` gives access to Nix packages
- `claudeCode.model` - Sets the model to "sonnet" (an alias for claude-sonnet-4-6)
- `claudeCode.tools.allowed` - List of tools the agent is permitted to use

> **Nix Terminology**: In Nix, `{ ... }` defines an attribute set (like a dictionary). The `...` means "accept any additional arguments" - this is standard Nix module syntax.

### 2. Module System

Yuki uses Nix's module system. This means profiles can be composed together:

```nix
# Compose multiple profiles - they merge deterministically
imports = [
  ./profiles/base.nix      # Base settings (model, basic tools)
  ./profiles/rust-dev.nix  # Rust-specific (cargo, clippy in PATH)
  ./profiles/security.nix  # Security restrictions (sandbox, no network)
];
```

**Explanation:**
- `imports` - Nix module system feature that loads other module files
- These profiles **merge** rather than override - lists concatenate, strings can append via `lib.mkAfter`

> **Nix Terminology**: *Module composition* is how NixOS and Yuki handle configuration. Each module declares options, and when multiple modules are imported, Nix merges them using defined semantics (lists combine, strings can use `mkAfter` to append).

### 3. Build Artifacts

When you run `nix build .#default`, Yuki produces a derivation in the Nix store:

```
/nix/store/xwl2sh0ajmfiv02n7jfdak4s6n8x89rj-yuki
```

This path encodes all your configuration—it's your audit trail.

> **Nix Terminology**: A *derivation* is Nix's term for a build recipe. The path includes a hash that represents all inputs (packages, configuration, etc.). If anything changes, the hash changes - providing cryptographic proof of what the environment contained.

## Ready-Made Profiles

Yuki ships with three profiles:

| Profile | Purpose |
|---------|---------|
| `default` | General purpose |
| `rust` | Rust development |
| `review` | Read-only code review |

## Nix Glossary

| Term | Meaning |
|------|---------|
| **Derivation** | A build recipe in Nix; describes how to build something |
| **Nix store** | `/nix/store/` - where all built outputs live |
| **Content-addressed** | Path is based on contents, not arbitrary naming |
| **Flake** | A Nix 2.0+ feature for reproducible declarative configs |
| **evalModules** | Nix function that evaluates module configurations |
| **buildEnv** | Nix function that creates an environment with specified paths |
| **writeScriptBin** | Nix function that writes a shell script to the store |

## Next Steps

You've learned what Yuki is. Now proceed to [Your First Session](./first-session.md) to try it yourself.