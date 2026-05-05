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

## Step 2: Set Up Authentication

Yuki needs access to an LLM API. Set your API key:

```bash
# Option 1: Environment variable (temporary)
export ANTHROPIC_API_KEY="sk-ant-..."

# Option 2: Create a .env file (recommended)
echo 'ANTHROPIC_API_KEY="sk-ant-..."' > .env
```

Add `.env` to your `.gitignore` if it contains secrets.

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

## Step 5: Try a One-Shot Prompt

Exit the REPL (type `exit` or Ctrl+D), then try a non-interactive prompt:

```bash
./result/bin/yuki "What files are in this repository?"
```

The agent responds and exits—no REPL needed.

## Understanding What Happened

When you ran `nix build .#default`, Yuki:

1. **Evaluated** your profile configuration (default.nix)
2. **Resolved** all dependencies (toolchain, MCP servers) to Nix store paths
3. **Generated** a shell script that sets up the environment
4. **Produced** a content-addressed derivation

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

## Next Steps

Now that you've run your first session:

| Want to... | Read next |
|------------|-----------|
| Create custom profiles | [How-to: Create a Profile](../howto/howto-create-profile.md) |
| Set up team standardization | [How-to: Team Setup](../howto/howto-team-setup.md) |
| Configure CI/CD | [How-to: CI/CD](../howto/howto-cicd.md) |
| Understand the design | [Explanation: Philosophy](../explanation/explanation-philosophy.md) |