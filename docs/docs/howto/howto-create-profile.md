---
sidebar_position: 1
title: Create a Custom Profile
description: Create a Yuki profile tailored to your project's needs
---

# How to Create a Custom Profile

## Goal

Create a custom Yuki profile with specific tools, environment, and permissions for your project.

## When to Use This Guide

- You want to customize the agent's capabilities
- Your project needs specific tools or environment
- You want to restrict agent permissions

## Step 1: Create a Profile File

Create a new file in the `profiles/` directory:

```nix
# profiles/my-project.nix
# This is a Nix module - a function that returns configuration
{ lib, pkgs, ... }:

{
  # Model selection - which AI model to use
  claudeCode.model = "sonnet";

  # Tool permissions - which tools the agent can use
  claudeCode.tools.allowed = [
    "read"
    "write"
    "edit"
    "bash"
    "grep"
    "glob"
  ];
  
  # Tools explicitly denied (filtered from allowed)
  claudeCode.tools.denied = [
    "execute"  # Disable command execution for safety
  ];

  # Hermetic toolchain - packages available in PATH
  # using 'with pkgs;' brings package attributes into scope
  claudeCode.toolchain.packages = with pkgs; [
    rustc
    cargo
    clippy
  ];

  # Environment variables injected into the session
  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
  };

  # System prompt additions - use lib.mkAfter to append to base
  claudeCode.systemPrompt = lib.mkAfter ''
    You are working on a Rust project.
    Always run 'cargo clippy' before marking tasks complete.
  '';

  # Sandbox configuration
  claudeCode.sandbox = {
    enable = true;
    allowNetwork = false;
    writablePaths = [ "/tmp" ];
  };
}
```

**Explanation of key Nix concepts:**

| Element | Meaning |
|---------|---------|
| `{ lib, pkgs, ... }:` | Function arguments. `lib` provides utilities like `mkAfter`, `pkgs` provides packages, `...` accepts any additional args |
| `with pkgs;` | Brings pkgs attributes into scope so you can write `rustc` instead of `pkgs.rustc` |
| `lib.mkAfter` | A Nix lib function that marks content to be appended (used for system prompt composition) |
| `claudeCode = { ... }` | The Yuki option namespace - all Yuki config lives under this attribute |

> **NOTE**: The `with pkgs;` syntax is idiomatic Nix. It temporarily adds `pkgs.` prefix to all identifiers. Without it, you'd need `pkgs.rustc`, `pkgs.cargo`, etc.

## Step 2: Add Profile to Flake

Edit `flake.nix` to include your new profile:

```nix
# flake.nix
{
  outputs = { self, nixpkgs, flake-utils }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    # mkHarness is the function that builds your profile
    mkHarness = modules:
      import ./lib/mkHarness.nix {
        inherit pkgs modules;
        modulePath = ./modules;
      };
  in
  {
    packages.x86_64-linux = {
      # Your custom profile - compose with default
      my-project = mkHarness [
        ./profiles/default.nix   # Base configuration
        ./profiles/my-project.nix  # Your customizations
      ];
      
      # Existing profiles still work
      default = mkHarness [ ./profiles/default.nix ];
      rust = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
    };
    
    # Also expose mkHarness for users who want to compose
    lib.mkHarness = mkHarness;
  };
}
```

**Explanation:**
- `legacyPackages.x86_64-linux` - Access Nix packages for the x86_64-linux platform
- `import ./lib/mkHarness.nix` - Loads the harness builder (returns a function)
- `mkHarness [ modules ]` - Calls the function with your module list
- `.#default` in `nix build .#default` refers to `packages.x86_64-linux.default`

> **NOTE**: The flake outputs `packages` attribute is what `nix build .#name` accesses. The `.#` syntax means "get the `name` output from the default flake".

## Step 3: Build and Test

```bash
# Build your profile
nix build .#my-project

# Run it
./result/bin/yuki
```

> **NOTE**: After building, `./result/bin/yuki` is a symlink to the generated shell script in the Nix store. The script sets up your environment every time it runs.

## Profile Composition

You can compose multiple profiles:

```nix
# Combine base + customizations
# Nix merges them - lists concatenate, strings can use mkAfter
my-profile = mkHarness [
  ./profiles/default.nix      # Base settings (model, basic tools)
  ./profiles/rust-dev.nix    # Rust toolchain (cargo, clippy)
  ./profiles/security.nix    # Restricted permissions (sandbox, no network)
];
```

**How Nix module merging works:**
- Lists (like `tools.allowed`) - Concatenated together
- Strings (like `systemPrompt`) - Use `lib.mkAfter` to append, or last value wins
- Booleans - Last value wins (can use `mkIf` for conditional)

> **NOTE**: This deterministic merging is the same mechanism NixOS uses for system configuration - it's why composition works reliably.

## Quick Reference: Available Options

| Option | Type | Description |
|--------|------|-------------|
| `claudeCode.model` | string | Model name (e.g., "sonnet", "opus") |
| `claudeCode.tools.allowed` | list | Tools the agent may use |
| `claudeCode.tools.denied` | list | Tools explicitly blocked |
| `claudeCode.toolchain.packages` | list | Packages in PATH (from `pkgs.*`) |
| `claudeCode.environment` | attrs | Environment variables |
| `claudeCode.systemPrompt` | string | System prompt (use `lib.mkAfter` to append) |
| `claudeCode.sandbox.enable` | bool | Enable sandbox |
| `claudeCode.sandbox.allowNetwork` | bool | Allow network access |

> **NOTE**: You can browse all options in `modules/default.nix` - that's the authoritative source for available configuration.

## See Also

- [Reference: Module Options](../reference/reference-options.md)
- [Tutorial: Your First Session](../tutorial/first-session.md)