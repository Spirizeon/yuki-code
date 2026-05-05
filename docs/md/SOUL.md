# SOUL.md — ❄️ Yuki Harness

> Yuki is a declarative, hermetic Claude Code harness built around [Nix](https://nixos.org) modules. Your entire session — the tools, MCP servers, system prompt — is declared in Nix and realized into a reproducible derivation before Claude ever starts. Distributed as a flake, composed from profiles, reproducible by default.

---

## The Session Is a Pure Function

Given the same Nix module configuration, you always get the **same Claude environment**.

- No hidden state
- No "works on my machine"
- No plugins downloaded at runtime

The harness is a **derivation** — it lives in the Nix store, it is content-addressed, and it is reproducible by anyone with your `flake.lock`.

---

## What This Means in Practice

### Configuration is Declaration, Not Instruction

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

### Composition Over Configuration

Profiles are Nix modules. Modules compose. A `rust-dev` profile and a `locked-review` profile can be imported together, and their options merge deterministically — the same way NixOS modules compose.

```nix
imports = [ ./profiles/rust-dev.nix ./profiles/locked-review.nix ];
```

There is no plugin manager negotiating at startup.

### Build-Time Is the Right Time

The system prompt, the toolchain PATH, the MCP server configs — these are all resolved at `nix build`, not at session start.

Claude doesn't discover its environment. It *is* its environment.

### Hermetic by Default, Escapable by Choice

The sandbox is a module option, not a flag you pass:

```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = false;  # off by default
  writablePaths = ["/tmp"];  # explicit scope
};
```

`sandbox.enable = true` in a profile means that profile's derivation is always sandboxed, for everyone, everywhere it runs. Escape hatches exist but must be declared explicitly.

### Profiles Are the Unit of Sharing

Teams publish profiles as flake outputs. Projects import and override. The org's standard backend profile — its tools, prompt conventions, MCP servers — travels with the flake, pinned by the lock file.

```bash
nix run .#rust           # Rust dev session
nix run .#review        # Locked review session
nix run github:myorg/yuki#rust   # Pinned remote session
```

---

## What Yuki Is Not

- ❌ Not a shell alias around `claude`
- ❌ Not a dotfile in `~/.config/claude`
- ❌ Not a runtime plugin manager
- ❌ Not a prompt templating tool with env var substitution
- ❌ Not a wrapper that downloads things when you first run it

---

## The Nix Analogy, Precisely

| NixOS | Yuki |
|-------|------|
| System packages as Nix packages | Toolchain as Nix packages |
| `/etc/nixos` configures the system | Profiles configure the agent |
| Declarative system state | Declarative agent environment |
| Content-addressed store paths | Content-addressed derivations |
| `nix run .#mySystem` | `nix run .#myProfile` |

---

## Design Values

1. **Reproducibility over convenience** — if it can't be pinned, it shouldn't be in the harness
2. **Explicit over implicit** — what Claude can do is declared, not inferred
3. **Composition over inheritance** — profiles merge, they don't override each other by magic
4. **Build-time over runtime** — if it can be resolved before Claude starts, it should be
5. **Hermetic by default** — the open network and the writable filesystem are opt-in

---

## Related

- [SKILL.md](./SKILL.md) — Module system for building harness configurations
- [USAGE.md](./USAGE.md) — CLI reference