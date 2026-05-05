---
sidebar_position: 3
title: Core Philosophy
description: The design values and principles behind Yuki
---

# Core Philosophy

Yuki is a declarative, hermetic Claude Code harness built around Nix modules. Your entire session - the tools, MCP servers, system prompt - is declared in Nix and realized into a reproducible derivation before Claude ever starts.

## The Session Is a Pure Function

Given the same Nix module configuration, you always get the **same Claude environment**.

- No hidden state
- No "works on my machine"
- No plugins downloaded at runtime

The harness is a derivation - it lives in the Nix store, it is content-addressed, and it is reproducible by anyone with your flake.lock.

## Configuration is Declaration, Not Instruction

You do not tell the harness what to do at runtime. You declare what the session *is*:

```nix
claudeCode = {
  model = "claude-sonnet-4-6";
  tools.allowed = [ "bash" "read" "write" "edit" "grep" "glob" ];
  toolchain.packages = [ pkgs.rustc pkgs.cargo pkgs.clippy ];
  sandbox.enable = true;
  sandbox.allowNetwork = false;
};
```

The harness realizes that declaration into a binary before Claude ever starts.

## Composition Over Configuration

Profiles are Nix modules. Modules compose. A `rust-dev` profile and a `locked-review` profile can be imported together, and their options merge deterministically.

```nix
imports = [ ./profiles/rust-dev.nix ./profiles/locked-review.nix ];
```

There is no plugin manager negotiating at startup.

## Build-Time Is the Right Time

The system prompt, the toolchain PATH, the MCP server configs - these are all resolved at `nix build`, not at session start.

Claude does not discover its environment. It *is* its environment.

## Hermetic by Default, Escapable by Choice

The sandbox is a module option, not a flag you pass:

```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = false;
  writablePaths = ["/tmp"];
};
```

`sandbox.enable = true` in a profile means that profile derivation is always sandboxed, for everyone, everywhere it runs. Escape hatches exist but must be declared explicitly.

## What Yuki Is Not

- Not a shell alias around `claude`
- Not a dotfile in `~/.config/claude`
- Not a runtime plugin manager
- Not a prompt templating tool with env var substitution
- Not a wrapper that downloads things when you first run it

## The Nix Analogy

| NixOS Modules | Yuki |
|--------|-----|
| System packages as Nix packages | Toolchain as Nix packages |
| `/etc/nixos` configures the OS | Profiles configure the agent |
| Declarative system state | Declarative agent environment |
| `nix run .#mySystem` | `nix run .#myProfile` |

## Design Values

1. **Reproducibility over convenience** - if it cannot be pinned, it should not be in the harness
2. **Explicit over implicit** - what Claude can do is declared, not inferred
3. **Composition over inheritance** - profiles merge, they do not override each other by magic
4. **Build-time over runtime** - if it can be resolved before Claude starts, it should be
5. **Hermetic by default** - the open network and the writable filesystem are opt-in

## See Also

- [Module System](./skill.md) - Building harness configurations
- [CLI Reference](./usage.md) - Detailed usage