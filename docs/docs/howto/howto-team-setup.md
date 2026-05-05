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
  # Fixed model version
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

  # Team conventions
  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    EDITOR = "vim";
  };

  claudeCode.systemPrompt = lib.mkAfter ''
    Follow team conventions:
    - Use conventional commits
    - Run tests before marking complete
    - Document new code
  '';
}
```

## Step 2: Publish as a Flake

Create a flake that exports your team configuration:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    yuki.url = "github:Spirizeon/yuki-code";
  };

  outputs = { self, nixpkgs, yuki }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    packages.x86_64-linux = {
      # Team profile combining Yuki + org-specific
      default = yuki.lib.mkHarness [
        yuki.profiles.default
        ./profiles/team-standard.nix
        ./profiles/org-security.nix
      ];
    };
  };
}
```

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

## Step 4: Version Control the Profile

Treat your profile like code:

```bash
# Pin to a specific Yuki version
git clone https://github.com/your-org/ai-config
cd ai-config

# Lock file pins all dependencies
cat flake.lock  # Shows pinned nixpkgs, yuki, etc.

# Update periodically
git pull        # Gets latest locked versions
```

## Team Workflow Example

| Action | Command |
|--------|---------|
| First time setup | `git clone && nix develop` |
| Daily use | `nix run .#default` |
| Update config | `git pull` |
| Test changes | `nix build .#default && ./result/bin/yuki` |

## Enforcing Consistency

Ensure everyone uses the same profile by:

1. **Documentation**: Document the expected workflow in your README
2. **CI validation**: Add CI checks that verify profiles build
3. **Onboarding**: Include Yuki setup in new developer docs

## See Also

- [How-to: CI/CD](howto-cicd.md)
- [How-to: Create Profile](howto-create-profile.md)
- [Reference: Module Options](../reference/reference-options.md)