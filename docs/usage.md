---
sidebar_position: 5
title: CLI Reference
description: Complete CLI reference for the yuki command
---

# CLI Reference

This guide covers the `yuki` CLI binary. For the Nix harness system, see [Core Philosophy](./soul.md) and [Module System](./skill.md).

## Quick Start

Run the doctor health check before prompts, sessions, or automation:

```bash
./rust/target/release/yuki
# first command inside the REPL
/doctor
```

`/doctor` is the built-in setup and preflight diagnostic.

## Prerequisites

- Rust toolchain with `cargo`
- One of:
  - `ANTHROPIC_API_KEY` for direct API access
  - `ANTHROPIC_AUTH_TOKEN` for bearer-token auth
- Optional: `ANTHROPIC_BASE_URL` when targeting a proxy or local service

## Build

```bash
# Using nix develop (recommended)
nix develop
cd rust
cargo build --release

# Or using system Rust
cd rust
cargo build --release
```

The CLI binary is available at `rust/target/release/yuki`.

## Commands

### Interactive REPL

```bash
./rust/target/release/yuki
```

### One-shot Prompt

```bash
./rust/target/release/yuki prompt "summarize this repository"
./rust/target/release/yuki "explain src/main.rs"
```

### Health Check

```bash
./rust/target/release/yuki doctor
./rust/target/release/yuki doctor --output-format json
```

### Model and Permission Controls

```bash
./rust/target/release/yuki --model sonnet prompt "review this diff"
./rust/target/release/yuki --permission-mode read-only prompt "summarize Cargo.toml"
./rust/target/release/yuki --allowedTools read,glob "inspect the runtime crate"
```

Supported permission modes:

- `read-only`
- `workspace-write`
- `danger-full-access`

Supported model aliases:

- `opus` - claude-opus-4-6
- `sonnet` - claude-sonnet-4-6
- `haiku` - claude-haiku-4-5-20251213

### Authentication

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export ANTHROPIC_AUTH_TOKEN="bearer-token"
export ANTHROPIC_BASE_URL="http://127.0.0.1:8080"  # for local proxy
```

### Local Models

OpenAI-compatible endpoints:

```bash
export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
export OPENAI_API_KEY="optional-key"
./rust/target/release/yuki --model llama3.2 prompt "hello"
```

## Session Management

REPL turns are persisted under `.yuki/sessions/`:

```bash
./rust/target/release/yuki --resume latest
./rust/target/release/yuki --resume latest /status /diff
```

## Common Commands

```bash
yuki status          # Show workspace status
yuki sandbox         # Show sandbox isolation
yuki agents          # List configured agents
yuki mcp             # Show MCP servers
yuki skills          # List skills
yuki system-prompt   # Show resolved system prompt
yuki init            # Create starter CLAUDE.md
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| ANTHROPIC_API_KEY | Direct API access |
| ANTHROPIC_AUTH_TOKEN | Bearer token auth |
| ANTHROPIC_BASE_URL | Proxy or local service |
| OPENAI_API_KEY | OpenAI-compatible auth |
| OPENAI_BASE_URL | OpenAI-compatible endpoint |
| HTTP_PROXY / HTTPS_PROXY | HTTP proxy |