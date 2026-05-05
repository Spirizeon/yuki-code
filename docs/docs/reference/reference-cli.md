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

## Commands

### Interactive REPL

```bash
yuki
```

Starts an interactive session. Type prompts, use slash commands.

### One-Shot Prompts

```bash
yuki "your prompt here"
yuki prompt "explicit prompt mode"
```

Send a single prompt and exit.

### Diagnostic Commands

| Command | Description |
|---------|-------------|
| `yuki doctor` | Health check (auth, config, workspace, sandbox) |
| `yuki doctor --output-format json` | JSON output for scripts |
| `yuki status` | Workspace status |
| `yuki sandbox` | Sandbox configuration |
| `yuki version` | Version information |
| `yuki system-prompt` | Show resolved system prompt |

### Session Management

| Command | Description |
|---------|-------------|
| `yuki --resume latest` | Resume latest session |
| `yuki --resume <session-id>` | Resume specific session |
| `yuki --resume ./path/to/session.jsonl` | Resume from file |

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

### Permission Modes

```bash
yuki --permission-mode read-only prompt "review"
yuki --permission-mode workspace-write prompt "implement"
yuki --permission-mode danger-full-access prompt "debug"
```

### Tool Restrictions

```bash
yuki --allowedTools read,glob prompt "find files"
```

### Output Format

```bash
yuki doctor --output-format json
yuki --output-format json prompt "task"
```

## Slash Commands (REPL)

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/status` | Session status |
| `/diff` | Show uncommitted changes |
| `/clear` | Clear session |
| `/cost` | Token usage |
| `/history` | Conversation summary |
| `/resume` | Resume session |
| `/commit` | Generate commit message |
| `/pr` | Create pull request |
| `/doctor` | Run diagnostics |
| `/mcp` | MCP server info |
| `/skills` | List skills |
| `/init` | Create CLAUDE.md |
| `/export` | Export conversation |

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ANTHROPIC_API_KEY` | Anthropic API key | Yes |
| `ANTHROPIC_AUTH_TOKEN` | Bearer token auth | No |
| `ANTHROPIC_BASE_URL` | Custom API endpoint | No |
| `OPENAI_API_KEY` | OpenAI-compatible key | No |
| `OPENAI_BASE_URL` | OpenAI-compatible endpoint | No |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage error |
| 130 | Interrupted (Ctrl+C) |

## Configuration Precedence

Yuki loads configuration in this order (later overrides earlier):

1. Command-line flags
2. `./.yuki/settings.json`
3. `./.yuki.json`
4. `$HOME/.yuki/settings.json`
5. Environment variables

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
# Get doctor output in JSON
yuki doctor --output-format json | jq '.auth.status'

# Check token usage
yuki --output-format json tokens | jq '.total'
```

### CI/CD

```bash
# In CI pipeline
export ANTHROPIC_API_KEY="$API_KEY"
nix run .#review --prompt "Review PR $PR_NUMBER"