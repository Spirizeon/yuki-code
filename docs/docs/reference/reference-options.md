---
sidebar_position: 2
title: Module Options
description: Complete reference for Yuki Nix module options
---

# Module Options Reference

This is the authoritative reference for all Yuki configuration options. These are Nix module options defined in `modules/default.nix`.

## Top-Level Options

### `claudeCode.enable`

```nix
claudeCode.enable = true;  # or false
```

Enable or disable the harness. When disabled, Yuki won't generate a profile.

**Default:** `true`

> **NOTE**: You rarely need to set this - it's primarily used internally or for conditional profiles using `lib.mkIf`.

---

### `claudeCode.model`

```nix
claudeCode.model = "sonnet";       # alias
claudeCode.model = "claude-sonnet-4-6";  # full name
```

Model to use. Accepts short aliases or full model identifiers.

**Allowed values:**
| Alias | Full Model |
|-------|------------|
| `opus` | claude-opus-4-6 |
| `sonnet` | claude-sonnet-4-6 |
| `haiku` | claude-haiku-4-5-20251213 |

**Default:** `claude-sonnet-4-6`

> **NOTE**: This sets the model at build time. The CLI's `--model` flag can override at runtime if needed.

---

## Tool Options

### `claudeCode.tools.allowed`

```nix
claudeCode.tools.allowed = [
  "read"
  "write"
  "edit"
  "bash"
  "grep"
  "glob"
  "websearch"
  "webfetch"
  "agent"
  "todo"
];
```

List of tools the agent may use. These are passed to Claude via the `CLAUDE_TOOLS` environment variable.

**Default:** All available tools

> **NOTE**: This is combined with `tools.denied` - the final allowed list is `allowed` minus `denied`.

---

### `claudeCode.tools.denied`

```nix
claudeCode.tools.denied = [ "execute" ];
```

Tools explicitly blocked from the allowed list.

**Default:** `[]` (empty - nothing denied)

> **NOTE**: Useful for creating restricted profiles. For example, the `review` profile denies `write`, `edit`, `bash`, `execute` to ensure read-only operation.

---

## Toolchain Options

### `claudeCode.toolchain.packages`

```nix
claudeCode.toolchain.packages = with pkgs; [
  rustc
  cargo
  clippy
  rustfmt
];
```

Packages to include in the agent's PATH. These are made available via Nix's `buildEnv`.

**Default:** `[]` (empty)

> **NOTE**: The packages are built/ fetched during `nix build`. The `buildEnv` creates a single directory with symlinks to all packages, which is prepended to PATH when the session starts.

---

## Environment Options

### `claudeCode.environment`

```nix
claudeCode.environment = {
  RUST_BACKTRACE = "1";
  EDITOR = "vim";
};
```

Environment variables to inject into the session. These are exported in the generated shell script.

**Default:** `{}` (empty)

> **NOTE**: These are set via `export KEY=value` in the startup script. They're available to both the yuki CLI and any spawned processes.

---

### `claudeCode.envFile`

```nix
claudeCode.envFile = ./secrets.env;
```

Path to a `.env` file to source at session start. Useful for loading API keys and other secrets.

**Default:** `null` (not set)

> **NOTE**: The file is sourced with `set -a` which exports all variables. This is better than hardcoding secrets in the profile.

---

## System Prompt Options

### `claudeCode.systemPrompt`

```nix
# Base prompt
claudeCode.systemPrompt = ''
  You are a Rust developer.
'';

# Append using mkAfter (recommended for composition)
claudeCode.systemPrompt = lib.mkAfter ''
  Always run cargo clippy before completing tasks.
'';
```

System prompt added to the agent's context. Use `lib.mkAfter` to append to base profile prompts.

**Default:** `""` (empty)

**Tips:**
- Use `lib.mkAfter` for composition (adds to end of existing prompt)
- Use plain assignment for complete override
- The prompt is written to `.yuki/CLAUDE.md` at session start

> **NOTE**: This is the core of Yuki's composability. Base profiles set a base prompt, and project-specific profiles append with `mkAfter`.

---

## MCP Server Options

### `claudeCode.mcp.servers`

```nix
claudeCode.mcp.servers = {
  "my-server" = {
    command = "${pkgs.mcp-server}/bin/mcp-server";
    args    = [ "--port" "3000" ];
    env     = { API_KEY = "value"; };
  };
};
```

MCP server configurations. Each server is identified by a name.

**Structure:**
- `command` (required): Path to executable (must be in Nix store)
- `args` (optional): List of command-line arguments
- `env` (optional): Environment variables for the server

**Default:** `{}` (empty - no MCP servers)

> **NOTE**: MCP servers are started by the yuki CLI at session initialization. The configuration is written to `~/.yuki/settings.json`.

---

## Sandbox Options

### `claudeCode.sandbox.enable`

```nix
claudeCode.sandbox.enable = true;
```

Enable sandbox isolation. When true, restricts the agent's capabilities.

**Default:** `false`

> **NOTE**: The sandbox restricts file system access and network. Use `sandbox.enable = true` for untrusted code review or CI automation.

---

### `claudeCode.sandbox.allowNetwork`

```nix
claudeCode.sandbox.allowNetwork = false;
```

Allow network access in sandbox. Requires `sandbox.enable = true`.

**Default:** `false`

> **NOTE**: Network access is disabled by default for security. Enable it only when the agent needs to make HTTP requests (e.g., data science workloads).

---

### `claudeCode.sandbox.writablePaths`

```nix
claudeCode.sandbox.writablePaths = [ "/tmp" ];
```

Paths writable within the sandbox. Requires `sandbox.enable = true`.

**Default:** `["/tmp"]`

> **NOTE**: Only these directories can be written to when sandbox is enabled. Add project-specific paths like `"./src"` if needed.

---

## Quick Reference Table

| Option | Type | Default |
|--------|------|---------|
| `claudeCode.enable` | bool | `true` |
| `claudeCode.model` | string | `"sonnet"` |
| `claudeCode.tools.allowed` | list | (all tools) |
| `claudeCode.tools.denied` | list | `[]` |
| `claudeCode.toolchain.packages` | list | `[]` |
| `claudeCode.environment` | attrs | `{}` |
| `claudeCode.envFile` | path | `null` |
| `claudeCode.systemPrompt` | string | `""` |
| `claudeCode.mcp.servers` | attrs | `{}` |
| `claudeCode.sandbox.enable` | bool | `false` |
| `claudeCode.sandbox.allowNetwork` | bool | `false` |
| `claudeCode.sandbox.writablePaths` | list | `["/tmp"]` |

---

## Nix Module Terminology

| Term | Meaning in This Context |
|------|------------------------|
| `bool` | Boolean (true/false) |
| `string` | Text value |
| `list` | Ordered collection (`[ "a" "b" ]`) |
| `attrs` | Attribute set (`{ key = value; }`) |
| `path` | File path (string or path literal) |
| `lib.mkAfter` | Appends to existing string option |
| `lib.mkIf` | Conditionally includes option |
| `with pkgs;` | Brings pkgs attributes into scope |

> **NOTE**: This is standard Nix module syntax. The options are declared in `modules/default.nix` using NixOS module conventions.

## See Also

- [How-to: Create Profile](../howto/howto-create-profile.md)
- [How-to: MCP Servers](../howto/howto-mcp-servers.md)