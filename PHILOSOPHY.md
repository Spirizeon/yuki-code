# Yuki Philosophy

## Stop Staring at the Files

If you only look at the generated files in this repository, you are looking at the wrong layer.

The Python rewrite was a byproduct. The Rust rewrite was also a byproduct. The real thing worth studying is the **system that produced them**: a clawhip-based coordination loop where humans give direction and autonomous claws execute the work.

## The Nix Foundation

Yuki is built around **Nix modules** — not shell scripts, not dotfile managers, not runtime plugin loaders. The entire Claude environment is declared in Nix and realized into a hermetic derivation **before Claude ever starts**.

This means:

- **The session is a pure function** — given the same Nix module configuration, you always get the same Yuki environment. No hidden state. No "works on my machine." No plugins downloaded at runtime.
- **Hermetic by default** — the toolchain, MCP servers, system prompt, and sandbox settings all live in the Nix store. It's content-addressed and reproducible by anyone with your `flake.lock`.
- **Build-time is the right time** — the system prompt, toolchain PATH, MCP server configs — these are resolved at `nix build`, not at session start. Claude doesn't discover its environment; it *is* its environment.
- **Explicit over implicit** — what Claude can do is declared, not inferred. Every tool, every MCP server, every sandbox boundary is a Nix option.

### The Three-Part System

#### 1. Nix Profiles

Profiles are Nix modules that declare what a session *is* — its tools, its context, its boundaries. A `rust-dev` profile and a `locked-review` profile can be imported together, and their options merge deterministically. There is no plugin manager negotiating at startup.

**Composition over configuration.** Profiles compose via Nix imports:
```nix
imports = [ ./profiles/rust-dev.nix ./profiles/locked-review.nix ];
```

#### 2.clawhip
[clawhip](https://github.com/Yeachan-Heo/clawhip) is the event and notification router.

It watches:
- git commits
- tmux sessions
- GitHub issues and PRs
- agent lifecycle events
- channel delivery

Its job is to keep monitoring and delivery **outside** the coding agent's context window.

#### 3. OmO (`oh-my-openagent`)
[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) handles multi-agent coordination.

When Architect, Executor, and Reviewer disagree, OmO provides the structure for that loop to converge.

## The Human Interface Is Discord

The important interface is not tmux, Vim, SSH, or a terminal multiplexer.

The real human interface is a Discord channel.

A person can type a sentence from a phone, walk away, sleep, or do something else. The claws read the directive, break it into tasks, assign roles, write code, run tests, argue over failures, recover, and push when the work passes.

## Hermetic by Default, Escapable by Choice

The sandbox is a module option, not a flag you pass:

```nix
claudeCode.sandbox = {
  enable = true;
  allowNetwork = false;  # network is off by default
  writablePaths = ["/tmp"];  # write scope is explicit
};
```

`claudeCode.sandbox.enable = true` in a profile means that profile's derivation is always sandboxed, for everyone, everywhere it runs. Escape hatches exist but must be declared explicitly.

## Profiles Are the Unit of Sharing

Teams publish profiles as flake outputs. Projects import and override. The org's standard backend profile — its tools, prompt conventions, MCP servers — travels with the flake, pinned by the lock file.

```bash
nix run .#rust           # Rust dev session
nix run .#review         # Locked review session
nix run github:myorg/yuki#rust   # Pinned remote session
```

## What Still Matters

As coding intelligence gets cheaper and more available, the durable differentiators are not raw coding output.

What still matters:
- product taste
- direction
- system design
- human trust
- operational stability
- judgment about what to build next
- **hermetic reproducibility**

In that world, the job of the human is not to out-type the machine.
The job of the human is to decide what deserves to exist.

## Design Values

1. **Reproducibility over convenience** — if it can't be pinned, it shouldn't be in the harness
2. **Explicit over implicit** — what Claude can do is declared, not inferred
3. **Composition over inheritance** — profiles merge, they don't override each other by magic
4. **Build-time over runtime** — if it can be resolved before Claude starts, it should be
5. **Hermetic by default** — the open network and the writable filesystem are opt-in

## Short Version

**Yuki is a demo of autonomous software development with hermetic Nix foundations.**

Humans provide direction.
Yuki coordinates, builds, tests, recovers, and pushes.
The repository is the artifact.
The philosophy is the system behind it — declarative, reproducible, composable.