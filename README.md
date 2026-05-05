# Yuki - Reproducible Agent Sessions

Hey everyone! So you've probably been there - you set up Claude Code on your machine, everything works great, and then your teammate pulls your code and... nothing works. Different tools, different prompts, different permissions. It's the classic "works on my machine" problem, but for AI coding agents.

That's exactly what Yuki solves.

---

## Index

- [What is Yuki?](#what-is-yuki)
- [The Core Problem](#the-core-problem)
- [How It Works](#how-it-works)
- [Quick Start](#quick-start)
- [Three Real-World Use Cases](#three-real-world-use-cases)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## What is Yuki?

Yuki is a declarative harness for Claude Code that treats agent sessions as **build artifacts**. 

In plain English: you define what your AI agent should have (tools, permissions, environment, MCP servers) in Nix configuration files, and Yuki builds a reproducible environment from those definitions.

The key insight? Your agent session becomes a pure function:

```
Your Config → nix build → /nix/store/...yuki → Claude Code
```

Everything is resolved at build time—before the agent even starts.

---

## The Core Problem

Here's what goes wrong without Yuki:

| Problem | What Happens |
|---------|-------------|
| Tool versions | Dev has Rust 1.80, CI has 1.75 → different clippy warnings |
| System prompts | One dev edited CLAUDE.md, another didn't → different behavior |
| MCP servers | Downloads deps at runtime → inconsistent across machines |
| Environment variables | Machine-specific exports → secrets leaked or missing |
| Tool permissions | Set interactively, not declared → audit nightmare |

There's no "lock file" for your agent's operating environment—until now.

---

## How It Works

The magic is in the Nix store path:

```
/nix/store/xwl2sh0ajmfiv02n7jfdak4s6n8x89rj-yuki
```

That hash encodes **everything**:
- Exact tool versions
- System prompt contents  
- MCP server binaries
- Sandbox configuration
- Environment variables

Change anything in your config? The hash changes. That's your audit trail.

---

## Quick Start

```bash
# Clone and build
git clone https://github.com/Spirizeon/yuki-code
cd yuki-code
nix build .#default

# Run the hermetic session
./result/bin/yuki
```

That's it! Three commands and you have a reproducible agent session.

### Ready-Made Profiles

| Command | Use Case |
|---------|----------|
| `nix run .#default` | Base tools + REPL |
| `nix run .#rust` | Rust development |
| `nix run .#review` | Read-only, sandboxed code review |

---

## Three Real-World Use Cases

### 1. Team Standardization

Every developer runs the exact same profile:

```bash
nix run .#backend  # identical on every machine
```

No more "what tools do I need to install?" questions.

### 2. CI/CD Reproducibility

Same profile in CI as local:

```yaml
- run: nix run .#review --prompt "Review PR $PR"
```

No more "it worked locally but failed in CI" mysteries.

### 3. Compliance & Audit

The Nix store path is your proof:

```bash
ls /nix/store/ | grep yuki
# -> /nix/store/xwl2sh0ajmfiv02n7jfdak4s6n8x89rj-yuki
```

That path proves exactly what the agent could do—critical for regulated environments.

---

## Documentation

For the full deep-dive, check out the docs at **[yuki.berzi.one](https://yuki.berzi.one)**:

| Section | What's Covered |
|---------|----------------|
| **Tutorials** | Getting started, your first session |
| **How-to Guides** | Create profiles, team setup, CI/CD, MCP servers |
| **Reference** | CLI commands, module options |
| **Explanation** | Core philosophy and design decisions |

The docs are written in the Diátaxis framework—clear distinction between tutorials (learning), how-to guides (doing), reference (looking up), and explanation (understanding).

---

## Contributing

Want to contribute? Here's how:

```bash
# Enter dev environment
nix develop

# Build the CLI
cd rust
cargo build --release

# Test
cargo test --release
```

Check out the full contributor guide at **[yuki.berzi.one](https://yuki.berzi.one)** for details.

---

## Built On

Yuki builds on [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code)—the Rust implementation of the Claude CLI. The core insight comes from NixOS: treating configuration as code, with reproducible builds as a first-class property.

---

**Bottom line:** If your team uses AI coding agents and you've ever uttered "it works on my machine," Yuki is for you.

Check out the docs at **[yuki.berzi.one](https://yuki.berzi.one)** to get started!