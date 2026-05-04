# SOUL.md — Yuki Harness

> Yuki is a [Claude Code](https://claude.ai/code) distribution built around [Nix](https://nixos.org) modules. Your entire session — the tools Claude can invoke, the MCP servers it connects to, the system prompt it reasons from — is declared in Nix and realized into a hermetic derivation before Claude ever starts. Distributed as a flake, composed from profiles, reproducible by default.

---

## Core Philosophy

**The session is a pure function.**

Given the same Nix module configuration, you always get the same Claude environment. No hidden state. No "works on my machine." No plugins downloaded at runtime. The harness is a derivation — it lives in the Nix store, it is content-addressed, and it is reproducible by anyone with your `flake.lock`.

This is not a wrapper script. It is not a dotfile manager. It is a **realized artifact** — the same way NixVim produces a configured Neovim derivation, Yuki produces a configured Claude Code session derivation.

---

## What This Means in Practice

**Configuration is declaration, not instruction.**
You do not tell the harness what to do at runtime. You declare what the session *is* — its tools, its context, its boundaries — and the harness realizes that declaration into a binary before Claude ever starts.

**Composition over configuration.**
Profiles are modules. Modules compose. A `rust-dev` profile and a `locked-review` profile can be imported together, and their options merge deterministically — the same way NixOS modules compose `/etc`. There is no plugin manager negotiating at startup.

**Build-time is the right time.**
The system prompt, the toolchain PATH, the MCP server configs — these are all resolved at `nix build`, not at session start. Claude doesn't discover its environment; it *is* its environment.

**Hermetic by default, escapable by choice.**
The sandbox is a module option, not a flag you pass. `sandbox.enable = true` in a profile means that profile's derivation is always sandboxed, for everyone, everywhere it runs. Escape hatches exist but must be declared explicitly.

**Profiles are the unit of sharing.**
Teams publish profiles as flake outputs. Projects import and override. The org's standard backend profile — its tools, prompt conventions, MCP servers — travels with the flake, pinned by the lock file.

---

## What Yuki Is Not

- Not a shell alias around `claude`
- Not a dotfile in `~/.config/claude`
- Not a runtime plugin manager
- Not a prompt templating tool with env var substitution
- Not a wrapper that downloads things when you first run it

---

## The Nix Analogy, Precisely

| NixVim | Yuki |
|---|---|
| Wraps Neovim | Wraps Claude Code |
| Plugins as Nix packages | MCP servers as Nix packages |
| `init.lua` generated from modules | System prompt assembled from modules |
| Treesitter, LSP as module options | Toolchain, sandbox as module options |
| Profile = set of enabled modules | Profile = set of enabled modules |
| `nix run .#neovim` | `nix run .#yuki` |

---

## Design Values

1. **Reproducibility over convenience** — if it can't be pinned, it shouldn't be in the harness
2. **Explicit over implicit** — what Claude can do is declared, not inferred
3. **Composition over inheritance** — profiles merge, they don't override each other by magic
4. **Build-time over runtime** — if it can be resolved before Claude starts, it should be
5. **Hermetic by default** — the open network and the writable filesystem are opt-in