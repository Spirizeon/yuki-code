---
sidebar_position: 2
title: Quick Start
description: Get up and running with Yuki in minutes
---

# Quick Start

Get Yuki running in your project in under 5 minutes.

## Prerequisites

- Nix with flakes enabled
- Git

## Installation

```bash
git clone https://github.com/Spirizeon/yuki-code
cd yuki-code
```

## For Users

### Build a Profile

```bash
# Default profile (base tools)
nix build .#default

# Rust development
nix build .#rust

# Read-only review (sandboxed)
nix build .#review
```

### Run Yuki

```bash
# Interactive REPL
./result/bin/yuki

# One-shot prompt
./result/bin/yuki "explain the architecture"
```

### Set Up Authentication

```bash
# Add to your shell profile or .env
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Test It Works

```bash
# Run health check
./result/bin/yuki doctor
```

## For Teams - Add to Your Project

### Option 1: Use Remote Profile

```nix
# myproject/flake.nix
{
  inputs.yuki.url = "github:Spirizeon/yuki-code";

  outputs = { self, yuki }: {
    packages.default = yuki.lib.mkHarness [
      yuki.profiles.default
    ];
  };
}
```

```bash
nix run .
```

### Option 2: Custom Profile

```nix
# myproject/flake.nix
{
  inputs.yuki.url = "github:Spirizeon/yuki-code";

  outputs = { self, yuki, ... }: {
    packages.default = yuki.lib.mkHarness [
      yuki.profiles.rust
      {
        claudeCode.systemPrompt = lib.mkAfter ''
          This project uses Django with PostgreSQL.
          Always run migrations before starting the server.
        '';
      }
    ];
  };
}
```

## For Contributors

### Development Environment

```bash
# Enter dev shell with all tools
nix develop

# Build the CLI
cd rust
cargo build --release
cd ..

# Test your changes
./rust/target/release/yuki --version

# Run tests
cargo test --workspace
```

### Run Tests

```bash
# Rust tests
cd rust
cargo test --release

# Nix builds
nix build .#default
nix build .#rust
nix build .#review
```

## Verify Your Setup

Run these checks:

```bash
# 1. Build succeeds
nix build .#default

# 2. Binary works
./result/bin/yuki --version

# 3. Doctor passes
./result/bin/yuki doctor

# 4. Run a test prompt
echo "Test prompt" | ./result/bin/yuki "echo 'hello'"
```

## Next Steps

| Goal | Action |
|------|--------|
| Understand design | Read [Core Philosophy](./soul.md) |
| Create custom profiles | Read [Module System](./skill.md) |
| CLI details | Read [CLI Reference](./usage.md) |