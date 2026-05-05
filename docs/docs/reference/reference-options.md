---
sidebar_position: 2
title: Module Options
description: Complete reference for Yuki Nix module options
---

# Module Options Reference

## Top-Level Options

### `claudeCode.enable`

```nix
claudeCode.enable = true;  # or false
```

Enable or disable the harness. Default: `true`.

---

### `claudeCode.model`

```nix
claudeCode.model = "sonnet";       # alias
claudeCode.model = "claude-sonnet-4-6";  # full name
```

Model to use. Accepts aliases or full model names.

**Allowed values:** `opus`, `sonnet`, `haiku`, or full model strings

**Default:** `claude-sonnet-4-6`

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

List of tools the agent may use.

**Default:** `["read" "write" "edit" "bash" "grep" "glob" "websearch" "webfetch" "agent" "todo"]`

---

### `claudeCode.tools.denied`

```nix
claudeCode.tools.denied = [ "execute" "edit" ];
```

Tools explicitly blocked from the allowed list.

**Default:** `[]`

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

Packages to include in the agent's PATH.

**Default:** `[]`

---

## Environment Options

### `claudeCode.environment`

```nix
claudeCode.environment = {
  RUST_BACKTRACE = "1";
  EDITOR = "vim";
};
```

Environment variables injected into the session.

**Default:** `{}`

---

### `claudeCode.envFile`

```nix
claudeCode.envFile = ./secrets.env;
```

Path to a `.env` file to source at session start.

**Default:** `null`

---

## System Prompt Options

### `claudeCode.systemPrompt`

```nix
claudeCode.systemPrompt = ''
  You are a Rust developer.
'';

# Append using mkAfter
claudeCode.systemPrompt = lib.mkAfter ''
  Always run cargo clippy before completing tasks.
'';
```

System prompt added to the agent's context.

**Default:** `""`

**Tip:** Use `lib.mkAfter` to append to base profile prompts.

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

MCP server configurations.

**Structure:**
- `command` (required): Path to executable
- `args` (optional): List of arguments
- `env` (optional): Environment variables

**Default:** `{}`

---

## Sandbox Options

### `claudeCode.sandbox.enable`

```nix
claudeCode.sandbox.enable = true;
```

Enable sandbox isolation.

**Default:** `false`

---

### `claudeCode.sandbox.allowNetwork`

```nix
claudeCode.sandbox.allowNetwork = false;
```

Allow network access in sandbox.

**Default:** `false`

---

### `claudeCode.sandbox.writablePaths`

```nix
claudeCode.sandbox.writablePaths = [ "/tmp" ];
```

Paths writable within the sandbox.

**Default:** `["/tmp"]`

---

## Quick Reference Table

| Option | Type | Default |
|--------|------|---------|
| `claudeCode.enable` | bool | `true` |
| `claudeCode.model` | string | `"sonnet"` |
| `claudeCode.tools.allowed` | list | (see above) |
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

## See Also

- [How-to: Create Profile](../howto/howto-create-profile.md)
- [How-to: MCP Servers](../howto/howto-mcp-servers.md)