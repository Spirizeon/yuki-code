---
sidebar_position: 1
slug: /
title: Introduction
description: Reproducible Agent Sessions for AI Engineering Teams
---

# Yuki - Reproducible Agent Sessions

Yuki is a declarative harness for Claude Code that treats agent sessions as build artifacts. Built on Nix, it provides reproducibility, auditability, and team standardization for AI engineering teams.

## Why Yuki?

Production AI engineering teams face critical challenges:

| Challenge | Without Yuki | With Yuki |
|-----------|--------------|-----------|
| **Environment consistency** | "Works on my machine" | Identical derivations everywhere |
| **Audit trails** | No capability proof | Content-addressed store path |
| **Team onboarding** | "Install these tools" | `nix run .#backend` |
| **CI/CD** | Config drift | Same profile in CI |
| **Compliance** | Unverifiable | Cryptographic proof |

## The Core Insight

Yuki treats the agent session as a **pure function**:

```
Nix Module Config → Derivation → /nix/store/...-yuki
```

Everything is resolved at **build time** before the agent starts:
- Model selection (pinned)
- Tool permissions (explicit allowlist/denylist)
- Toolchain (hermetic PATH from Nix packages)
- Environment variables (declared)
- System prompt (composable)
- MCP servers (resolved to Nix store)
- Sandbox policy (network/filesystem)

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

| Profile | Purpose |
|---------|---------|
| default | Base tools + REPL |
| rust | Rust development with toolchain |
| review | Read-only, sandboxed code review |

## Production Use Cases

### Team Standardization

Publish a shared profile:

```nix
# your-org/flake.nix
{
  inputs.yuki.url = "github:your-org/yuki-config";

  outputs = { self, yuki }: {
    packages.backend = yuki.lib.mkHarness {
      modules = [
        yuki.profiles.default
        yourorg.backend-tools
        yourorg.security-policy
      ];
    };
  };
}
```

Every developer runs `nix run .#backend` - identical everywhere.

### CI/CD Reproducibility

```yaml
# .github/workflows/ai-review.yml
steps:
  - uses: actions/checkout@v4
  - run: nix run .#review --prompt "Review PR $PR"
```

The review agent gets:
- Same model as local
- Same tool permissions (read-only)
- Same system prompt
- Same sandbox (no network, no writes)

### Compliance and Audit

The Nix store path encodes all inputs:

```bash
# What did this agent have access to?
ls /nix/store/ | grep yuki
# -> /nix/store/xwl2sh0ajmfiv02n7jfdak4s6n8x89rj-yuki

# That path IS the audit trail
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Yuki                                 │
├─────────────────────────────────────────────────────────────┤
│  profiles/*.nix        →  Module compositions              │
│  modules/default.nix   →  Option schema (claudeCode.*)     │
│  lib/mkHarness.nix     →  Derivation builder               │
│  flake.nix             →  Flake outputs                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    /nix/store/...yuki
                            ↓
                    Claude Code Session
```

## Next Steps

- [Core Philosophy](./soul.md) - Design values and principles
- [Module System](./skill.md) - Creating custom profiles
- [CLI Reference](./usage.md) - Complete CLI documentation