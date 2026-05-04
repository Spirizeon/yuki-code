# AGENTS.md — Claude Harness

Specialized agents for building, validating, and composing harness configurations.

---

## Agent Index

| Agent | Trigger | What it does |
|---|---|---|
| `profile-generator` | User describes a dev environment in natural language | Produces a `.nix` profile module |
| `module-validator` | User pastes or writes a module/profile | Type-checks options, catches common mistakes |
| `prompt-assembler` | User wants to preview the final system prompt | Runs evalModules and renders the merged `systemPrompt` |
| `mcp-auditor` | User wants to review MCP server surface area | Lists all MCP servers across imported profiles and their permissions |
| `sandbox-advisor` | User asks what sandbox settings to use | Recommends sandbox config based on the profile's tool set |
| `flake-scaffolder` | User wants a new harness project from scratch | Generates the full flake + module + profiles directory structure |

---

## Agent: `profile-generator`

**Trigger**: User describes a language, framework, or workflow in prose. E.g. "I want a profile for Go microservices work" or "set me up for reviewing Python PRs."

**Inputs**:
- Natural language description of the environment
- Optional: existing profiles to compose with

**Process**:
1. Identify the language/toolchain → map to `pkgs.*` packages
2. Identify any MCP servers that would help (docs, LSP, search)
3. Draft a system prompt fragment appropriate for the domain
4. Determine default tool permissions (write-heavy for active dev, read-only for review)
5. Determine sandbox posture (network needed? which paths writable?)

**Output**: A complete `.nix` profile module ready to drop into `profiles/`:

```nix
# profiles/<name>.nix
{ config, lib, pkgs, ... }:
{
  claudeCode.toolchain.packages = [ ... ];
  claudeCode.environment = { ... };
  claudeCode.systemPrompt = lib.mkAfter '' ... '';
  claudeCode.mcp.servers.<name> = { ... };
  claudeCode.sandbox = { ... };
}
```

**Rules**:
- Always use `lib.mkAfter` for `systemPrompt` — never assign directly
- Always use versioned/pinned packages from nixpkgs, never `pkgs.latest.*`
- Never set `tools.denied = []` explicitly — omit if not restricting
- Sandbox off by default for active dev profiles; on by default for review profiles

---

## Agent: `module-validator`

**Trigger**: User pastes a profile or module and asks if it's correct, or after `profile-generator` produces output.

**Inputs**: A `.nix` module or profile

**Process**:
1. Check all option paths exist in the schema (`claudeCode.*`)
2. Check types: `listOf str` vs `str`, `attrsOf` shapes, bool flags
3. Check `systemPrompt` uses `lib.mkAfter` not bare string assignment
4. Check `toolchain.packages` contains valid attribute paths
5. Check `mcp.servers` entries have required `command` field
6. Flag any `tools.allowed` / `tools.denied` conflicts (same tool in both)
7. Flag sandbox mismatches: `allowNetwork = true` with `tools.denied = ["bash"]` is suspicious

**Output**: Annotated diff or list of issues with suggested fixes. If clean, confirm with "✓ module looks correct."

---

## Agent: `prompt-assembler`

**Trigger**: User wants to preview what the final system prompt will look like after all profiles are merged. E.g. "what does my system prompt actually say?" or "show me the assembled CLAUDE.md."

**Inputs**: List of profile paths or module expressions to compose

**Process**:
1. Simulate `evalModules` merge order (respect `lib.mkBefore`/`lib.mkAfter` priorities)
2. Concatenate `systemPrompt` fragments in priority order
3. Render the final string with section dividers showing which profile contributed which fragment

**Output**:

```
=== Assembled CLAUDE.md ===

[from: profiles/default.nix]
You are a careful, methodical engineer...

[from: profiles/rust-dev.nix  (mkAfter)]
You are working in a Rust project.
Always run `cargo clippy` before marking tasks complete.

[from: profiles/locked-review.nix  (mkAfter)]
This is a read-only review session. Do not write or modify files.
```

---

## Agent: `mcp-auditor`

**Trigger**: User asks "what MCP servers does this harness expose?" or wants to review the attack surface before a locked/review session.

**Inputs**: Composed module set (list of profiles)

**Process**:
1. Collect all `claudeCode.mcp.servers.*` entries across all imported profiles
2. For each server: name, command path, args, env vars exposed
3. Cross-reference with `tools.allowed` — flag if MCP server is registered but `mcp` is not in allowed tools
4. Flag any servers that pass secrets via args (should use env) 
5. Flag any servers with `allowNetwork = true` in a sandboxed profile

**Output**: Table of all MCP servers with their surface area and any warnings.

---

## Agent: `sandbox-advisor`

**Trigger**: User asks "should I sandbox this?" or "what sandbox settings make sense for X profile?"

**Inputs**: A profile or description of what Claude will be doing

**Process**:
1. If `tools.allowed` includes `bash` or `write` → active dev posture → sandbox optional, network likely needed
2. If `tools.allowed` is read-only subset → review posture → sandbox strongly recommended, network off
3. If MCP servers are present → check if they need network → set `allowNetwork` accordingly
4. Determine minimum `writablePaths` for the use case

**Output**: Recommended sandbox block with rationale:

```nix
# Recommended for this profile:
claudeCode.sandbox = {
  enable = true;          # read-only review — sandbox on
  allowNetwork = false;   # no MCP servers need outbound access
  writablePaths = [ "/tmp" ];  # no project writes needed
};
# Rationale: tools.allowed is read-only; no reason to expose filesystem or network.
```

---

## Agent: `flake-scaffolder`

**Trigger**: User wants to start a new Claude Harness project from scratch.

**Inputs**:
- Project name
- Initial profiles wanted (or description of use cases)
- Whether this is an org-level harness or a per-project harness

**Process**:
1. Generate directory structure
2. Generate `flake.nix` with correct inputs and `mkHarness` calls
3. Generate `modules/default.nix` with full option declarations
4. Generate `lib/mkHarness.nix` with evalModules + derivation builder
5. Generate one starter profile per requested use case (delegates to `profile-generator`)
6. Generate `README.md` with the pitch lede and usage examples

**Output**: Complete file tree ready to `git init` and `nix flake check`:

```
my-claude-harness/
├── flake.nix
├── flake.lock
├── lib/
│   └── mkHarness.nix
├── modules/
│   └── default.nix
├── profiles/
│   ├── default.nix
│   ├── rust-dev.nix
│   └── locked-review.nix
└── README.md
```

---

## Composition Rules (all agents follow these)

1. **Never clobber `systemPrompt`** — always `lib.mkAfter` or `lib.mkBefore`
2. **Never mutate shared state** — profiles declare, they do not execute
3. **Sandbox is additive** — a more restrictive profile wins; you cannot un-sandbox via import order
4. **Tool lists merge, not replace** — `allowed` and `denied` concatenate across profiles; conflicts must be resolved explicitly
5. **MCP servers are named** — two profiles providing `mcp.servers.docs` will conflict at evalModules time; names must be unique or one must override with `lib.mkForce`
