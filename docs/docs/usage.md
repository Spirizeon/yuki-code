---
sidebar_position: 5
title: CLI Reference
description: Complete CLI reference for the yuki command for production teams
---

# CLI Reference

Complete reference for the `yuki` CLI binary. For the harness system, see [Module System](./skill.md).

## Building and Running

### From Nix (Recommended)

```bash
# Build a profile
nix build .#default

# Run the built profile
./result/bin/yuki

# Or use nix run
nix run .#default
```

### From Source

```bash
# Enter dev environment
nix develop

# Build
cd rust
cargo build --release

# Run
cd ..
./rust/target/release/yuki
```

## Command Overview

```
yuki [global-options] [command] [arguments]

Commands:
  yuki                  Start interactive REPL
  yuki prompt TEXT      Send one prompt and exit
  yuki [TEXT]           Shorthand non-interactive prompt
  yuki --resume SESSION Resume saved session

Diagnostic:
  yuki doctor           Health check (auth, config, workspace, sandbox)
  yuki status           Workspace status snapshot
  yuki sandbox          Sandbox isolation status
  yuki version          Version and build info
  yuki system-prompt    Show resolved system prompt

Management:
  yuki init             Create CLAUDE.md in current directory
  yuki export           Export conversation to markdown
  yuki mcp              Show MCP server configuration
  yuki skills           List available skills
  yuki agents           List configured agents
  yuki session          Manage sessions (list, switch, fork, delete)
```

## Interactive REPL

```bash
# Start REPL
yuki

# Inside REPL, use slash commands
/help          # Show available commands
/status        # Show current session status
/diff          # Show uncommitted changes
/commit        # Generate commit message
/pr            # Create pull request
/clear         # Start fresh session
/resume        # Resume saved session
```

## One-Shot Prompts

```bash
# Simple prompt (non-interactive, exits after response)
yuki "what is this project about?"

# Explicit prompt mode
yuki prompt "summarize the architecture"

# With output format
yuki --output-format json prompt "count lines of code"
```

## Model Selection

```bash
# Use model alias (recommended)
yuki --model sonnet prompt "review PR #123"
yuki --model opus prompt "implement feature X"
yuki --model haiku prompt "quick question"

# Use full model name
yuki --model claude-sonnet-4-6 prompt "task description"
```

Supported aliases:
| Alias | Full Model |
|-------|------------|
| opus | claude-opus-4-6 |
| sonnet | claude-sonnet-4-6 |
| haiku | claude-haiku-4-5-20251213 |

## Permission Modes

```bash
# Read-only (sandboxed, no writes)
yuki --permission-mode read-only prompt "review this code"

# Workspace write (default)
yuki --permission-mode workspace-write prompt "implement feature"

# Danger (no restrictions)
yuki --permission-mode danger-full-access prompt "run tests"
```

## Tool Restrictions

```bash
# Limit to specific tools
yuki --allowedTools read,glob "find all TODO comments"
yuki --allowedTools read,write,edit "implement the feature"
```

## Session Management

```bash
# Resume latest session
yuki --resume latest

# Resume specific session
yuki --resume abc123

# Resume from file
yuki --resume ./sessions/abc123.jsonl

# Inside REPL
/resume latest
/resume abc123
/session list
/session switch abc123
```

## Authentication

### Environment Variables

```bash
# Direct API access (recommended)
export ANTHROPIC_API_KEY="sk-ant-..."

# Bearer token auth
export ANTHROPIC_AUTH_TOKEN="bearer-token..."

# Proxy or local service
export ANTHROPIC_BASE_URL="http://localhost:8080"

# OpenAI-compatible (Ollama, LM Studio, etc.)
export OPENAI_BASE_URL="http://localhost:11434/v1"
export OPENAI_API_KEY="optional-key"
```

### Production Best Practices

1. **Use environment files** - Don't hardcode keys in scripts
2. **CI/CD secrets** - Use GitHub secrets or vault
3. **Rotation** - Rotate API keys regularly

```bash
# Using .env file (add to .gitignore)
export $(cat .env | xargs)  # Load from .env
yuki prompt "..."
```

## Diagnostic Commands

### Health Check

```bash
# Human-readable output
yuki doctor

# JSON output (for scripts/CI)
yuki doctor --output-format json
```

### Workspace Status

```bash
yuki status
yuki status --output-format json
```

### Sandbox Status

```bash
yuki sandbox
yuki sandbox --output-format json
```

### System Prompt

```bash
# Show resolved prompt (with all composes)
yuki system-prompt

# With date
yuki system-prompt --date 2026-01-15

# Specific working directory
yuki system-prompt --cwd /path/to/project
```

## Slash Commands Reference

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/status` | Session status |
| `/diff` | Show uncommitted changes |
| `/clear` | Clear session |
| `/cost` | Token usage |
| `/history` | Conversation summary |
| `/tokens` | Token count |
| `/resume` | Resume session |
| `/session` | Manage sessions |
| `/commit` | Generate commit |
| `/pr` | Create PR |
| `/issue` | Create issue |
| `/init` | Create CLAUDE.md |
| `/mcp` | MCP server info |
| `/skills` | List skills |
| `/agents` | List agents |
| `/doctor` | Run diagnostics |
| `/config` | Show config |
| `/export` | Export conversation |

## Configuration Files

Yuki loads configuration from (in order of precedence):

1. Command-line flags
2. `$CLAUDE_CONFIG_HOME/.yuki/settings.json`
3. `./.yuki/settings.json`
4. `./.yuki.json`
5. `$HOME/.yuki/settings.json`

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage error (bad arguments) |
| 130 | Interrupted (Ctrl+C) |

## Environment Variables Reference

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `ANTHROPIC_AUTH_TOKEN` | Bearer token |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `OPENAI_API_KEY` | OpenAI-compatible key |
| `OPENAI_BASE_URL` | OpenAI-compatible endpoint |
| `HTTP_PROXY` | HTTP proxy |
| `HTTPS_PROXY` | HTTPS proxy |
| `NO_COLOR` | Disable colored output |
| `CLAUDE_CONFIG_HOME` | Config directory |

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Yuki
  run: |
    nix run .#default --prompt "Review PR ${{ github.event.pull_request.number }}"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### GitLab CI

```yaml
yuki-review:
  script:
    - nix run .#review --prompt "Review MR $CI_MR_NUMBER"
  variables:
    ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

### Scripting with JSON Output

```bash
# Parse doctor output
yuki doctor --output-format json | jq '.auth.status'

# Check sandbox
yuki sandbox --output-format json | jq '.networkAllowed'

# Count tokens
yuki tokens | grep "Total"
```