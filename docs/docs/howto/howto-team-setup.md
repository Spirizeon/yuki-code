---
sidebar_position: 2
title: Set Up Team Standardization
description: Create a shared Yuki configuration for your entire team
---

# How to Set Up Team Standardization

## Goal

Establish a standardized agent configuration that every team member can use, ensuring consistency across local development and CI/CD.

## When to Use This Guide

- Onboarding new team members
- Enforcing team-wide conventions
- Ensuring CI matches local environments

## Step 1: Create a Team Profile

Create a shared profile in your organization's repository:

```nix
# profiles/team-standard.nix
{ lib, pkgs, ... }:

{
  # Fixed model version - same for everyone
  claudeCode.model = "sonnet";

  # Standard tools for your stack
  claudeCode.tools.allowed = [
    "read"
    "write"
    "edit"
    "bash"
    "grep"
    "glob"
    "websearch"
  ];

  # Team conventions via environment
  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    EDITOR = "vim";
  };

  # Team-specific instructions via system prompt
  claudeCode.systemPrompt = lib.mkAfter ''
    Follow team conventions:
    - Use conventional commits
    - Run tests before marking complete
    - Document new code
  '';
}
```

**Why this works:**
- Every team member uses the **same model** (no "I had better results with opus")
- Everyone has the **same tools** (no "I don't have that tool installed")
- Environment variables are **declared** (no machine-specific exports)
- System prompt is **version-controlled** (no drift over time)

> **NOTE**: The key benefit is that `flake.lock` pins all dependencies. When someone runs `nix build`, they get the exact same environment as everyone else.

## Step 2: Publish as a Flake

Create a flake that exports your team configuration:

```nix
# flake.nix
{
  inputs = {
    # Pin nixpkgs to a specific version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Import Yuki as a dependency
    yuki.url = "github:Spirizeon/yuki-code";
  };

  outputs = { self, nixpkgs, yuki }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    packages.x86_64-linux = {
      # Team profile - combine Yuki base + org-specific config
      default = yuki.lib.mkHarness [
        yuki.profiles.default
        ./profiles/team-standard.nix
        ./profiles/org-security.nix
      ];
    };
  };
}
```

**Explanation of inputs:**
- `inputs` declares dependencies with versions (from lock file)
- `nixpkgs.url` - The Nix packages repository (pinned in flake.lock)
- `yuki.url` - Your Yuki dependency (pinned version)

> **NOTE**: The `flake.lock` file is crucial - it records exactly which versions everything resolved to. Commit this file to ensure reproducibility.

## Step 3: Share with Team

Team members clone the flake and use:

```bash
# Clone your org's flake
git clone https://github.com/your-org/ai-config
cd ai-config

# Build team-standard environment
nix build .#default

# Run with team settings
./result/bin/yuki
```

**What happens:**
1. Nix reads `flake.lock` to get exact versions
2. Builds the profile (fetches/patches packages)
3. Produces a derivation in `/nix/store/...`
4. Creates `./result/bin/yuki` pointing to it

> **NOTE**: The first build may take time (downloading packages), but subsequent builds are instant due to Nix's caching.

## Step 4: Version Control the Profile

Treat your profile like code:

```bash
# Clone and enter directory
git clone https://github.com/your-org/ai-config
cd ai-config

# The lock file pins all dependencies - this is your guarantee
cat flake.lock  # Shows pinned nixpkgs, yuki, etc.

# Update periodically (review changes in git diff)
git pull        # Gets latest locked versions
```

**The lock file guarantees:**
- Same `nixpkgs` revision
- Same Yuki version
- Same any other inputs

> **NOTE**: The `flake.lock` is auto-generated. Don't edit it manually - run `nix flake update` to update dependencies.

## Team Workflow Example

| Action | Command | What Happens |
|--------|---------|--------------|
| First time setup | `git clone && nix develop` | Enters dev shell with all tools |
| Daily use | `nix run .#default` | Builds and runs profile |
| Update config | `git pull` | Gets latest locked versions |
| Test changes | `nix build .#default && ./result/bin/yuki` | Verifies profile works |

> **NOTE**: `nix develop` enters a shell with packages from `devShells` - useful for working on the flake itself.

## Enforcing Consistency

Ensure everyone uses the same profile by:

1. **Documentation**: Document the expected workflow in your README
2. **CI validation**: Add CI checks that verify profiles build
3. **Onboarding**: Include Yuki setup in new developer docs

## See Also

- [How-to: CI/CD](howto-cicd.md)
- [How-to: Create Profile](howto-create-profile.md)
- [Reference: Module Options](../reference/reference-options.md)