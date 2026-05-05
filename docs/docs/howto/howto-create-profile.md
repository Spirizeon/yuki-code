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
{ lib, pkgs, ... }:

{
  # Model selection
  claudeCode.model = "sonnet";

  # Tool permissions
  claudeCode.tools.allowed = [
    "read"
    "write"
    "edit"
    "bash"
    "grep"
    "glob"
  ];
  
  claudeCode.tools.denied = [
    "execute"  # Disable command execution
  ];

  # Hermetic toolchain
  claudeCode.toolchain.packages = with pkgs; [
    rustc
    cargo
    clippy
  ];

  # Environment variables
  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
  };

  # System prompt additions
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

## Step 2: Add Profile to Flake

Edit `flake.nix` to include your new profile:

```nix
# flake.nix
{
  outputs = { self, nixpkgs, flake-utils }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    mkHarness = modules:
      import ./lib/mkHarness.nix {
        inherit pkgs modules;
        modulePath = ./modules;
      };
  in
  {
    packages.x86_64-linux = {
      # Your custom profile
      my-project = mkHarness [
        ./profiles/default.nix
        ./profiles/my-project.nix
      ];
      
      # Existing profiles
      default = mkHarness [ ./profiles/default.nix ];
      rust = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
    };
  };
}
```

## Step 3: Build and Test

```bash
# Build your profile
nix build .#my-project

# Run it
./result/bin/yuki
```

## Profile Composition

You can compose multiple profiles:

```nix
# Combine base + customizations
my-profile = mkHarness [
  ./profiles/default.nix      # Base settings
  ./profiles/rust-dev.nix    # Rust toolchain
  ./profiles/security.nix    # Restricted permissions
];
```

The Nix module system merges them deterministically.

## Quick Reference: Available Options

| Option | Type | Description |
|--------|------|-------------|
| `claudeCode.model` | string | Model name (e.g., "sonnet", "opus") |
| `claudeCode.tools.allowed` | list | Tools the agent may use |
| `claudeCode.tools.denied` | list | Tools explicitly blocked |
| `claudeCode.toolchain.packages` | list | Packages in PATH |
| `claudeCode.environment` | attrs | Environment variables |
| `claudeCode.systemPrompt` | string | System prompt (use `lib.mkAfter` to append) |
| `claudeCode.sandbox.enable` | bool | Enable sandbox |
| `claudeCode.sandbox.allowNetwork` | bool | Allow network access |

## See Also

- [Reference: Module Options](../reference/reference-options.md)
- [Tutorial: Your First Session](../tutorial/first-session.md)