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

Everything is resolved at **build time**—before the agent starts.

## Key Concepts

### 1. Profiles

A profile is a collection of settings that define an agent session:

```nix
# A simple profile
{ lib, pkgs, ... }: {
  claudeCode.model = "sonnet";
  claudeCode.tools.allowed = [ "read" "grep" "glob" ];
}
```

### 2. Module System

Yuki uses Nix's module system. This means profiles can be composed together:

```nix
# Compose multiple profiles
imports = [
  ./profiles/base.nix      # Base settings
  ./profiles/rust-dev.nix  # Rust-specific
  ./profiles/security.nix  # Security restrictions
];
```

### 3. Build Artifacts

When you run `nix build`, Yuki produces a derivation in the Nix store:

```
/nix/store/xwl2sh0ajmfiv02n7jfdak4s6n8x89rj-yuki
```

This path encodes all your configuration—it's your audit trail.

## Ready-Made Profiles

Yuki ships with three profiles:

| Profile | Purpose |
|---------|---------|
| `default` | General purpose |
| `rust` | Rust development |
| `review` | Read-only code review |

## Next Steps

You've learned what Yuki is. Now proceed to [Your First Session](./first-session.md) to try it yourself.