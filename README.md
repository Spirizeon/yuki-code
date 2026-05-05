# Yuki - Reproducible Agent Sessions for AI Engineering Teams

<p align="center">
  <a href="https://github.com/Spirizeon/yuki-code/stargazers">
    <img src="https://img.shields.io/github/stars/Spirizeon/yuki-code?style=flat" alt="GitHub stars">
  </a>
  <a href="https://github.com/Spirizeon/yuki-code/releases/latest">
    <img src="https://img.shields.io/github/v/release/Spirizeon/yuki-code" alt="GitHub release">
  </a>
  <a href="https://github.com/Spirizeon/yuki-code/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/Spirizeon/yuki-code" alt="License MIT">
  </a>
  <a href="https://nixos.org">
    <img src="https://img.shields.io/badge/Powered%20by-Nix-blue" alt="Nix">
  </a>
</p>

## The Problem: "Works on My Machine" for AI Agents

Modern AI coding agents like Claude Code are powerful, but their deployment suffers from a fundamental reproducibility crisis:

| Source of Irreproducibility | What Goes Wrong |
|-----------------------------|------------------|
| **Tool versions** | Developer has Rust 1.80, CI has 1.75 - different clippy warnings |
| **System prompts** | One developer edited CLAUDE.md, another did not - different behavior |
| **MCP servers** | Server downloads deps at runtime - inconsistent across machines |
| **Environment variables** | Machine-specific exports - secrets leaked or missing |
| **Tool permissions** | Set interactively, not declared - audit nightmare |

Teams fall back to informal conventions (make sure you have Rust installed), but there is no mechanism analogous to a lock file for the agent operating environment.

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

### Why This Matters for AI Engineering Teams

| Team Challenge | Yuki Answer |
|---------------|-------------|
| Works on my machine | Same derivation everywhere |
| CI vs local divergence | Identical Nix store path |
| Audit requirements | Content-addressed store path encodes full config |
| Onboarding new engineers | nix run .#backend gets exact same setup |
| Regulatory compliance | Cryptographic proof of what the agent could do |

## Key Distinguishing Features

### 1. Declarative, Not Imperative

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

The harness realizes this declaration into a binary before Claude starts.

### 2. Hermetic by Default

The sandbox is a module option, not a runtime flag:

```nix
claudeCode.sandbox = {
  enable = true;              # always on for this profile
  allowNetwork = false;       # opt-in, not opt-out
  writablePaths = [ "/tmp" ]; # explicit scope
};
```

When sandbox.enable = true, that profile derivation is always sandboxed for everyone, everywhere it runs.

### 3. Profile Composition

Profiles are Nix modules that compose deterministically:

```nix
# Compose multiple profiles - they merge, do not conflict
imports = [
  ./profiles/rust-dev.nix
  ./profiles/security-review.nix
];
```

The Nix module system merge semantics ensure:
- List options (toolchain packages) concatenate
- String options (system prompt) append via lib.mkAfter
- Boolean options follow defined merge strategy

### 4. Content-Addressed Audit Trail

The Nix store path encodes all inputs:

```
/nix/store/3kx5k7s2...-yuki
```

Given this path, you can reconstruct:
- Exact tool versions
- System prompt contents
- MCP server binaries
- Sandbox configuration

This is a cryptographic proof of what the agent was capable of doing - critical for compliance and audit.

## For AI Engineering Teams: Three Real-World Use Cases

### Use Case 1: Team Standardization

Publish a shared profile as a flake output:

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

Every developer runs:
```bash
nix run .#backend  # identical on every machine
```

### Use Case 2: CI/CD Reproducibility

```yaml
# .github/workflows/ai-review.yml
steps:
  - uses: actions/checkout@v4
  - run: nix run .#review --prompt "Review PR ${{ github.event.pull_request.number }}"
```

The review agent receives:
- Same model as local development
- Same tool permissions (read-only)
- Same system prompt (team conventions)
- Same sandbox (no network, no writes)

No more "it worked locally but failed in CI" mysteries.

### Use Case 3: Compliance and Audit

For regulated environments, Yuki provides:

1. **Capability audit** - The store path proves what the agent could do
2. **Config reproducibility** - Same inputs -> same outputs, always
3. **No runtime drift** - Nothing downloaded after session starts

```bash
# Audit trail: what did this agent have access to?
ls -la /nix/store/ | grep yuki
# -> /nix/store/xwl2sh0ajmfiv02n7jfdak4s6n8x89rj-yuki

# Reconstruct full config from that path
# Yuki stores all config in the derivation
```

## Quick Start

```bash
# Clone and build
git clone https://github.com/spirizeon/yuki
cd yuki
nix build .#default

# Run the hermetic session
./result/bin/yuki
```

### Ready-Made Profiles

| Profile | Use Case |
|---------|----------|
| default | Base tools + REPL |
| rust | Rust development with toolchain |
| review | Read-only, sandboxed code review |

```bash
nix run .#rust        # Rust dev session
nix run .#review      # Locked review session
```

## Documentation

| Document | Purpose |
|----------|---------|
| [SOUL.md](./docs/md/SOUL.md) | Core philosophy and design values |
| [SKILL.md](./docs/md/SKILL.md) | Module system and profile authoring |
| [USAGE.md](./docs/md/USAGE.md) | CLI reference and examples |
| [DEV.md](./DEV.md) | Development guide for contributors |

## Development

```bash
# Enter dev environment
nix develop

# Build
cd rust
cargo build --release
cd ..
./result/bin/yuki --version

# See DEV.md for full contributor guide
```

## Ecosystem

- [clawhip](https://github.com/Yeachan-Heo/clawhip) - Event routing
- [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) - Multi-agent coordination

## Citation

If you use Yuki in research or want to cite the approach:

```bibtex
@article{yuki2025,
  title={Yuki: A Declarative, Hermetic Harness for Reproducible AI Coding Agent Environments},
  author={Spirizeon},
  journal={Workshop on Reproducible AI Development (RAID 25)},
  year={2025}
}
```

## Acknowledgments

Yuki is built on [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code), the Rust implementation of the Claude CLI agent harness. The core insight is treating agent sessions as build artifacts, following the same principles that make NixOS systems reproducible.