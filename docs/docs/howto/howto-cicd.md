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
      
      # Install Nix with flakes support
      - name: Install Nix
        uses: cachix/install-nix-action@v27
        with:
          extra_nix_config: |
            flakes = true
            nix-path = nixpkgs=github:NixOS/nixpkgs/nixos-unstable

      # Build the profile - uses flake.lock for reproducibility
      - name: Build profile
        run: nix build .#rust --print-build-logs

      # Run the agent with a prompt
      - name: Run review
        run: |
          echo "Reviewing code..." | ./result/bin/yuki prompt "Review the changes in this PR"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Key points in this workflow:**

| Step | Purpose |
|------|---------|
| `actions/checkout@v4` | Gets your code |
| `cachix/install-nix-action@v27` | Installs Nix with flakes enabled |
| `extra_nix_config` | Configures Nix to use the flake registry |
| `nix build .#rust` | Builds the profile using locked versions |
| `./result/bin/yuki prompt` | Runs a non-interactive prompt |

> **NOTE**: The workflow uses `flake.lock` to ensure CI gets exactly the same versions as local development. This eliminates "it works on my machine" issues.

## GitLab CI Example

Create `.gitlab-ci.yml`:

```yaml
stages:
  - review

yuki-review:
  image: nixos/nix:latest
  before_script:
    # Enable flakes in Nix configuration
    - nix profile install nixpkgs#nixFlakes
    - nix profile install nixpkgs#git
  script:
    - nix build .#review --print-build-logs
    - echo "Running code review..."
    - ./result/bin/yuki prompt "Review changes"
  variables:
    ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

**Explanation:**
- `image: nixos/nix:latest` - Uses official Nix image
- `before_script` - Installs flakes support and git
- `nix build .#review` - Builds the review profile

> **NOTE**: GitLab CI variables are set in project settings. Add `ANTHROPIC_API_KEY` there as a masked variable.

## Using Different Profiles

### For Code Review (Read-Only)

```bash
# Build the review profile (restricted permissions)
nix build .#review

# Run with read-only permissions
./result/bin/yuki --permission-mode read-only prompt "Review this code"
```

> **NOTE**: The review profile has `sandbox.enable = true` and `allowNetwork = false` - perfect for untrusted code review.

### For Automated Testing

```bash
# Build default profile
nix build .#default

# Run tests via agent
./result/bin/yuki prompt "Run cargo test and summarize results"
```

### For Documentation Generation

```bash
# Build with documentation tools
nix build .#default

# Generate docs
./result/bin/yuki prompt "Generate documentation for this crate"
```

## Secrets Management

### GitHub

Add your API key in repository settings:
1. Settings → Secrets and variables → Actions
2. Add `ANTHROPIC_API_KEY`

The workflow references it as: `${{ secrets.ANTHROPIC_API_KEY }}`

### GitLab

1. Settings → CI/CD → Variables
2. Add `ANTHROPIC_API_KEY` as a masked variable

The pipeline references it as: `$ANTHROPIC_API_KEY`

> **NOTE**: Never hardcode API keys in your repository. Always use secrets management.

## CI Best Practices

1. **Use the review profile** in CI for safety:
   ```nix
   # profiles/review.nix has these settings:
   claudeCode.sandbox = {
     enable = true;
     allowNetwork = false;
   };
   ```

2. **Pin versions** via `flake.lock`:
   ```bash
   # Don't regenerate lock file in CI - just build
   nix build .#profile
   ```

3. **Cache dependencies**:
   The `cachix/install-nix-action` handles caching automatically.

4. **Use `--print-build-logs`** for debugging:
   ```bash
   nix build .#profile --print-build-logs
   ```

> **NOTE**: CI runners may not have Nix pre-installed, so the install step is required. The `cachix/install-nix-action` handles this cleanly.

## Testing Your CI Locally

Before pushing, test locally using the same profile:

```bash
# Simulate CI environment - same profile as CI
nix build .#review

# Test the prompt
./result/bin/yuki prompt "Test prompt"
```

If it works locally, it will work in CI (same derivation).

## See Also

- [How-to: Team Setup](howto-team-setup.md)
- [Tutorial: First Session](../tutorial/first-session.md)