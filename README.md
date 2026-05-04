# ❄️ Yuki

<p align="center">
  <a href="https://github.com/spirizeon/yuki">spirizeon/yuki</a>
  ·
  <a href="https://github.com/ultraworkers/claw-code">ultraworkers/claw-code</a> (base)
  ·
  <a href="./SOUL.md">Philosophy</a>
  ·
  <a href="./SKILL.md">Skill</a>
  ·
  <a href="./USAGE.md">Usage</a>
  ·
  <a href="https://discord.gg/5TUQKqFWd">Discord</a>
</p>

<p align="center">
  <pre>
 .     .--. 
.-.          .-        .'|     |__| 
 \ \        / /      .'  |     .--. 
  \ \      / /      <    |     |  | 
   \ \    / /_    _  |   | ____|  | 
    \ \  / /| '  / | |   | \ .'|  | 
     \ `  /.' | .' | |   |/  . |  | 
      \  / /  | /  | |    /\  \|__| 
      / / |   `'.  | |   |  \  \    
  |`-' /  '   .'|  '/'    \  \  \   
   '..'    `-'  `--''------'  '---'
  </pre>
</p>

## The Session Is a Pure Function

Yuki is a **declarative**, **hermetic** Claude Code harness built on Nix. Your entire session — the tools Claude can invoke, the MCP servers it connects to, the system prompt it reasons from — is declared in Nix profiles and realized into a reproducible derivation **before Claude ever starts**.

```
profiles → evalModules → mkHarness → /nix/store/…-yuki
```

**This is not a wrapper script.** It's a realized artifact — the same way NixVim produces a configured Neovim derivation, Yuki produces a configured Claude Code session derivation.

## Why Nix?

| Without Nix | With Yuki |
|------------|----------|
| "works on my machine" | Same environment everywhere |
| Runtime plugin downloads | Build-time resolve |
| Implicit toolchain | Explicit packages in PATH |
| Mutable dotfiles | Declarative profiles |
| Unreproducible sessions | Content-addressed derivation |

## Quick Start

```bash
# Clone and enter the flake
git clone https://github.com/spirizeon/yuki
cd yuki

# Build a harness profile
nix build .#default
# or
nix build .#rust
# or  
nix build .#review

# Run the hermetic session
./result/bin/yuki
```

```bash
# Interactive from anywhere (after adding to PATH)
nix run github:spirizeon/yuki#rust
```

## Three Ways to Use Yuki

### 1. Flake Outputs (Recommended)

```bash
nix run .#default      # Base tools + REPL
nix run .#rust        # + Rust toolchain
nix run .#review      # Read-only, sandboxed
```

### 2. Nix Module Composition

Import profiles and compose your own:

```nix
# my-project/flake.nix
{
  inputs.yuki.url = "github:spirizeon/yuki";
  
  outputs = { self, yuki, ... }:
  {
    packages.default = yuki.lib.mkHarness {
      modules = [
        yuki.profiles.rust
        {
          claudeCode.systemPrompt = lib.mkAfter ''
            This project uses diesel for database access.
          '';
        }
      ];
    };
  };
}
```

### 3. Local Development

```bash
cd rust
cargo build --workspace
./target/debug/yuki
```

## What Yuki Declares

```nix
claudeCode = {
  model         # "claude-sonnet-4-6" — model to use
  tools.allowed # ["bash" "read" "write" ...] — permitted tools
  toolchain.packages = [ pkgs.rustc pkgs.clippy ];  # hermetic PATH
  environment = { RUST_BACKTRACE = "1"; };        # env vars
  systemPrompt = lib.mkAfter '' ... '';               # composable prompt
  mcp.servers = { };                              # MCP configurations
  sandbox = { enable = true; allowNetwork = false; };  # isolation
};
```

## Design Values

1. **Reproducibility over convenience** — if it can't be pinned, it shouldn't be in the harness
2. **Explicit over implicit** — what Claude can do is declared, not inferred
3. **Composition over inheritance** — profiles merge, they don't override each other by magic
4. **Build-time over runtime** — if it can be resolved before Claude starts, it should be
5. **Hermetic by default** — the open network and the writable filesystem are opt-in

## Documentation

- [SOUL.md](./SOUL.md) — Core philosophy (read this first)
- [SKILL.md](./SKILL.md) — Module system and profile authoring
- [USAGE.md](./USAGE.md) — CLI reference and usage
- [rust/README.md](./rust/README.md) — Rust implementation details

## Ecosystem

- [clawhip](https://github.com/Yeachan-Heo/clawhip) — Event routing
- [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) — Multi-agent coordination
- [UltraWorkers Discord](https://discord.gg/5TUQKqFWd)

## Acknowledgments

Yuki is built on the foundation of [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code), the original Rust implementation of the Claude CLI agent harness. This project carries forward its vision of autonomous software development with declarative, hermetic Nix-based environments.