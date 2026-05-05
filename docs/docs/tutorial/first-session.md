---
sidebar_position: 2
title: Your First Session
description: Set up and run your first Yuki agent session
---

# Your First Session

## What You Will Learn

By the end of this tutorial, you will:
- Install Yuki
- Run your first agent session
- Verify everything works correctly

## Prerequisites

Before starting, ensure you have:

- **Nix** with flakes enabled
- **Git**
- An **Anthropic API key** (or equivalent)

> **NOTE**: To enable Nix flakes, add `experimental-features = nix-command flakes` to your `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`.

## Step 1: Clone and Build

Open your terminal and run:

```bash
# Clone the repository
git clone https://github.com/Spirizeon/yuki-code
cd yuki-code

# Build the default profile
nix build .#default
```

This builds a Yuki profile from Nix modules. The output appears in `./result/`.

**Explanation:**
- `nix build .#default` - Tells Nix to build the `default` output from the flake
- `./result/` - A symlink to the built derivation in the Nix store
- `.#default` is shorthand for `.#packages.x86_64-linux.default`

> **NOTE**: The `.#` syntax is flake references. The part before `#` is the flake input (default = this repo), and after `#` is the output name.

## Step 2: Set Up Authentication

Yuki needs access to an LLM API. Set your API key:

```bash
# Option 1: Environment variable (temporary)
export ANTHROPIC_API_KEY="sk-ant-..."

# Option 2: Create a .env file (recommended)
echo 'ANTHROPIC_API_KEY="sk-ant-..."' > .env
```

Add `.env` to your `.gitignore` if it contains secrets.

> **NOTE**: Yuki can also load `.env` files via the `claudeCode.envFile` option in your profile - this lets you commit the profile without secrets.

## Step 3: Run Your First Session

Start the interactive REPL:

```bash
./result/bin/yuki
```

You should see a welcome message. Try a simple prompt:

```
Hello! What can you help me with?
```

## Step 4: Verify with Doctor Check

Run the built-in health check:

```bash
./result/bin/yuki doctor
```

This verifies:
- Authentication is working
- Configuration is valid
- Workspace is healthy
- Sandbox status (if enabled)

**Explanation:** The `doctor` command runs diagnostics without starting an agent session. It's useful for debugging configuration issues.

## Step 5: Try a One-Shot Prompt

Exit the REPL (type `exit` or Ctrl+D), then try a non-interactive prompt:

```bash
./result/bin/yuki "What files are in this repository?"
```

The agent responds and exits—no REPL needed.

**Explanation:** Non-interactive mode is useful for CI/CD pipelines or scripts. The session still uses your profile configuration (model, tools, environment).

## Understanding What Happened

When you ran `nix build .#default`, Yuki:

1. **Evaluated** your profile configuration (default.nix)
   - *Nix parses the module and merges with imported modules*

2. **Resolved** all dependencies (toolchain, MCP servers) to Nix store paths
   - *Nix fetches or builds each package, producing `/nix/store/...` paths*

3. **Generated** a shell script that sets up the environment
   - *`writeScriptBin` creates an executable in the store*

4. **Produced** a content-addressed derivation
   - *The hash in the path encodes all inputs - this is your audit trail*

The `./result/bin/yuki` script:
- Sets up the toolchain PATH
- Loads environment variables
- Writes system prompts to `.yuki/CLAUDE.md`
- Launches Claude Code with your permissions

## Common Issues

| Error | Solution |
|-------|----------|
| "API key not found" | Set `ANTHROPIC_API_KEY` environment variable |
| "command not found: yuki" | Ensure `./result/bin/` is in your PATH or run with `./result/bin/yuki` |
| "No such file or directory" | Run `nix build .#default` first |
| "flakes not enabled" | Add `experimental-features = nix-command flakes` to nix.conf |

> **NOTE**: If you see "No such file or directory", make sure you ran `nix build .#default` first. The `./result` symlink only appears after a successful build.

## Next Steps

Now that you've run your first session:

| Want to... | Read next |
|------------|-----------|
| Create custom profiles | [How-to: Create a Profile](../howto/howto-create-profile.md) |
| Set up team standardization | [How-to: Team Setup](../howto/howto-team-setup.md) |
| Configure CI/CD | [How-to: CI/CD](../howto/howto-cicd.md) |
| Understand the design | [Explanation: Philosophy](../explanation/explanation-philosophy.md) |