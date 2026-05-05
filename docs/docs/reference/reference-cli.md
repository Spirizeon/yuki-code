---
sidebar_position: 1
title: CLI Reference
description: Complete reference for the yuki command-line interface
---

# CLI Reference

## Command Structure

```
yuki [global-options] [command] [arguments]
```

The CLI accepts global options (like `--model`, `--permission-mode`), a command (optional), and arguments.

## Commands

### Interactive REPL

```bash
yuki
```

Starts an interactive session. Type prompts, use slash commands.

> **NOTE**: The REPL maintains conversation history and saves sessions to `.yuki/sessions/`.

### One-Shot Prompts

```bash
yuki "your prompt here"
yuki prompt "explicit prompt mode"
```

Send a single prompt and exit. Useful for CI/CD or scripts.

> **NOTE**: One-shot mode doesn't save conversation history - it's a stateless request.

### Diagnostic Commands

| Command | Description |
|---------|-------------|
| `yuki doctor` | Health check (auth, config, workspace, sandbox) |
| `yuki doctor --output-format json` | JSON output for scripts/CI |
| `yuki status` | Workspace status |
| `yuki sandbox` | Sandbox configuration |
| `yuki version` | Version information |
| `yuki system-prompt` | Show resolved system prompt (after all `lib.mkAfter` merges) |

> **NOTE**: The `doctor` command is the first thing to run when troubleshooting - it checks authentication, configuration validity, and sandbox status.

### Session Management

| Command | Description |
|---------|-------------|
| `yuki --resume latest` | Resume latest session |
| `yuki --resume <session-id>` | Resume specific session |
| `yuki --resume ./path/to/session.jsonl` | Resume from file |

Sessions are saved as JSONL (JSON Lines) files in `.yuki/sessions/`.

> **NOTE**: Use `yuki session list` to see available sessions, or check `.yuki/sessions/` directly.

### Management Commands

| Command | Description |
|---------|-------------|
| `yuki init` | Create CLAUDE.md in current directory |
| `yuki export` | Export conversation to markdown |
| `yuki mcp` | Show MCP server configuration |
| `yuki skills` | List available skills |
| `yuki agents` | List configured agents |

## Global Options

### Model Selection

```bash
yuki --model sonnet prompt "task"
yuki --model opus prompt "task"
yuki --model haiku prompt "task"
```

Model aliases:
| Alias | Full Model |
|-------|------------|
| `opus` | claude-opus-4-6 |
| `sonnet` | claude-sonnet-4-6 |
| `haiku` | claude-haiku-4-5-20251213 |

> **NOTE**: You can also use full model names directly. The profile's `claudeCode.model` sets the default, but `--model` overrides it.

### Permission Modes

```bash
yuki --permission-mode read-only prompt "review"
yuki --permission-mode workspace-write prompt "implement"
yuki --permission-mode danger-full-access prompt "debug"
```

| Mode | Description |
|------|-------------|
| `read-only` | Only read operations allowed (default in review profile) |
| `workspace-write` | Can write to workspace files |
| `danger-full-access` | No restrictions (use with caution) |

> **NOTE**: This corresponds to the `claudeCode.sandbox` settings. The `read-only` mode enforces `sandbox.enable = true` and `allowNetwork = false`.

### Tool Restrictions

```bash
yuki --allowedTools read,glob prompt "find files"
```

Comma-separated list of permitted tools. Overrides the profile's `tools.allowed`.

> **NOTE**: This is useful for quick testing without modifying the profile. The session still uses the profile's environment, toolchain, etc.

### Output Format

```bash
yuki doctor --output-format json
yuki --output-format json prompt "task"
```

Useful for CI/CD pipelines and scripting. Parsable with `jq`.

## Slash Commands (REPL)

These are used inside the interactive REPL:

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/status` | Session status |
| `/diff` | Show uncommitted changes |
| `/clear` | Clear session (start fresh) |
| `/cost` | Token usage for current session |
| `/history` | Conversation summary |
| `/resume` | Resume a saved session |
| `/commit` | Generate a commit message |
| `/pr` | Create a pull request (if GitHub CLI available) |
| `/doctor` | Run diagnostics within REPL |
| `/mcp` | Show MCP server info |
| `/skills` | List skills |
| `/init` | Create CLAUDE.md |
| `/export` | Export conversation |

> **NOTE**: Prefix commands with `/`. The REPL is stateful - you can continue a conversation across multiple prompts.

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ANTHROPIC_API_KEY` | Anthropic API key | Yes |
| `ANTHROPIC_AUTH_TOKEN` | Bearer token auth | No |
| `ANTHROPIC_BASE_URL` | Custom API endpoint | No |
| `OPENAI_API_KEY` | OpenAI-compatible key | No |
| `OPENAI_BASE_URL` | OpenAI-compatible endpoint | No |

> **NOTE**: Set these in your shell profile or pass them directly: `ANTHROPIC_API_KEY=xxx yuki prompt "..."`

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage error (bad arguments) |
| 130 | Interrupted (Ctrl+C) |

> **NOTE**: Exit code 2 indicates invalid arguments - check the error message for what's wrong.

## Configuration Precedence

Yuki loads configuration in this order (later overrides earlier):

1. Command-line flags (highest priority)
2. `./.yuki/settings.json` (project-specific)
3. `./.yuki.json` (alternative project location)
4. `$HOME/.yuki/settings.json` (user-specific)
5. Environment variables (lowest priority, but always applied)

> **NOTE**: The profile settings (model, tools, sandbox) are set at build time by Nix, not at runtime - this ensures consistency.

## Examples

### Basic Usage

```bash
# Interactive session
yuki

# One-shot prompt
yuki "summarize this codebase"

# Run with specific model
yuki --model opus "complex task"
```

### Scripting

```bash
# Get doctor output in JSON and check auth status
yuki doctor --output-format json | jq '.auth.status'

# Check token usage
yuki --output-format json tokens | jq '.total'

# Filter output
yuki --output-format json prompt "task" | jq '.content'
```

### CI/CD

```bash
# In CI pipeline - build then run
export ANTHROPIC_API_KEY="$API_KEY"
nix run .#review --prompt "Review PR $PR_NUMBER"
```

> **NOTE**: Using `nix run` builds the profile first (if needed), then runs yuki with the provided prompt.

## See Also

- [Tutorial: First Session](../tutorial/first-session.md)
- [How-to: CI/CD](../howto/howto-cicd.md)