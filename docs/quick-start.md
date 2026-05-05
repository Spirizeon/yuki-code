---
sidebar_position: 2
title: Quick Start
description: Get up and running with Yuki in minutes
---

# Quick Start

## Prerequisites

- Nix with flakes enabled
- Git

## Installation

```bash
git clone https://github.com/Spirizeon/yuki-code
cd yuki-code
```

## Build a Profile

```bash
# Build default profile
nix build .#default

# Or build specific profiles
nix build .#rust        # Rust development
nix build .#review      # Read-only code review
```

## Run Yuki

```bash
# Run the built profile
./result/bin/yuki
```

## Development

For contributors:

```bash
# Enter dev environment
nix develop

# Build the CLI
cd rust
cargo build --release

# Run tests
cargo test --release

# Return to root
cd ..
./result/bin/yuki --version
```

## Next Steps

- Read [Core Philosophy](./soul.md) to understand the design
- Check [Module System](./skill.md) to create custom profiles
- See [CLI Reference](./usage.md) for detailed usage