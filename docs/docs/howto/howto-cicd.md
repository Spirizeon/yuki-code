---
sidebar_position: 3
title: Set Up CI/CD
description: Configure continuous integration for Yuki-powered workflows
---

# How to Set Up CI/CD

## Goal

Configure your CI pipeline to use Yuki profiles, ensuring consistency between local development and automated runs.

## When to Use This Guide

- Running automated code reviews
- Running tests in a standardized environment
- Enforcing the same agent configuration in CI as local

## GitHub Actions Example

Create `.github/workflows/yuki.yml`:

```yaml
name: Yuki Agent

on:
  pull_request:
    paths:
      - '**.rs'
      - '**.nix'
  workflow_dispatch:

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v27
        with:
          extra_nix_config: |
            flakes = true
            nix-path = nixpkgs=github:NixOS/nixpkgs/nixos-unstable

      - name: Build profile
        run: nix build .#rust --print-build-logs

      - name: Run review
        run: |
          echo "Reviewing code..." | ./result/bin/yuki prompt "Review the changes in this PR"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## GitLab CI Example

Create `.gitlab-ci.yml`:

```yaml
stages:
  - review

yuki-review:
  image: nixos/nix:latest
  before_script:
    - nix profile install nixpkgs#nixFlakes
    - nix profile install nixpkgs#git
  script:
    - nix build .#review --print-build-logs
    - echo "Running code review..."
    - ./result/bin/yuki prompt "Review changes"
  variables:
    ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

## Using Different Profiles

### For Code Review (Read-Only)

```bash
nix build .#review
./result/bin/yuki --permission-mode read-only prompt "Review this code"
```

### For Automated Testing

```bash
nix build .#default
./result/bin/yuki prompt "Run cargo test and summarize results"
```

### For Documentation Generation

```bash
nix build .#default
./result/bin/yuki prompt "Generate documentation for this crate"
```

## Secrets Management

### GitHub

Add your API key in repository settings:
1. Settings → Secrets and variables → Actions
2. Add `ANTHROPIC_API_KEY`

### GitLab

1. Settings → CI/CD → Variables
2. Add `ANTHROPIC_API_KEY` as masked variable

## CI Best Practices

1. **Use the review profile** in CI for safety:
   ```nix
   claudeCode.sandbox = {
     enable = true;
     allowNetwork = false;
   };
   ```

2. **Pin versions** via `flake.lock`:
   ```bash
   # Don't regenerate lock file in CI
   # Just run: nix build .#profile
   ```

3. **Cache dependencies**:
   ```yaml
   - uses: cachix/install-nix-action@v27
   ```

## Testing Your CI Locally

Before pushing, test locally:

```bash
# Simulate CI environment
nix build .#review
./result/bin/yuki prompt "Test prompt"
```

## See Also

- [How-to: Team Setup](howto-team-setup.md)
- [Tutorial: First Session](../tutorial/first-session.md)