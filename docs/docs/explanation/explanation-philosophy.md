---
sidebar_position: 1
title: Core Philosophy
description: Understanding the design decisions behind Yuki
---

# Core Philosophy

## Why Yuki Exists

Modern AI coding agents are powerful, but their deployment is unreliable. Each developer has different tools installed. System prompts drift over time. MCP servers download dependencies at runtime. There's no audit trail of what the agent could do.

Yuki solves this by applying the same principles that make NixOS systems reproducible to AI agent sessions.

## The Core Insight

**Yuki treats the agent session as a pure function:**

```
Nix Module Config → Derivation → /nix/store/...-yuki
```

Given the same inputs, you always get the same output.

## Design Principles

### 1. Reproducibility Over Convenience

If something can't be pinned, it shouldn't be in the harness. Every tool, configuration, and dependency is resolved at build time.

- Tool versions are Nix packages
- System prompts are in modules
- MCP servers are in the Nix store
- Nothing is downloaded at runtime

### 2. Declarative Over Imperative

You declare *what* the session is, not *what* to do:

```nix
# Declarative - what it IS
claudeCode = {
  model = "sonnet";
  tools.allowed = [ "read" "bash" ];
};

# Imperative - what to DO (NOT how Yuki works)
# run --model sonnet --tools read,bash
```

### 3. Composition Over Inheritance

Profiles are Nix modules. They compose deterministically:

```nix
# These merge, they don't conflict
imports = [
  ./profiles/base.nix
  ./profiles/rust-dev.nix
  ./profiles/security.nix
];
```

### 4. Build-Time Over Runtime

Resolve everything before the agent starts:

```
User runs: nix build .#profile
            ↓
Nix evaluates modules
            ↓
Resolves toolchain to Nix store paths
            ↓
Generates shell script
            ↓
User runs: ./result/bin/yuki
            ↓
Agent starts with pre-resolved environment
```

### 5. Hermetic by Default

The sandbox is a module option, not a runtime flag:

```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = false;
};
```

`enable = true` means always sandboxed, for everyone, everywhere.

## The Nix Analogy

| NixOS | Yuki |
|-------|------|
| System packages | Toolchain packages |
| `/etc/nixos` configuration | Profile configuration |
| Declarative system state | Declarative agent state |
| Content-addressed store | Content-addressed derivations |
| Reproducible systems | Reproducible agent sessions |

## What Yuki Is Not

- Not a shell alias
- Not a runtime plugin manager
- Not a prompt templating tool
- Not a wrapper that downloads things at runtime

## Trade-offs

| Benefit | Trade-off |
|---------|------------|
| Reproducibility | Must use Nix |
| Declarative config | Learning curve for Nix |
| Audit trail | Store paths are long |
| Team standardization | Requires team buy-in |

## When to Use Yuki

- Team standardization is important
- CI/CD consistency matters
- Audit trails are required
- You value reproducibility

## When Not to Use Yuki

- Quick prototyping
- One-off tasks
- No Nix knowledge in team

## See Also

- [Tutorial: Getting Started](../tutorial/getting-started)
- [How-to: Team Setup](../howto/howto-team-setup.md)