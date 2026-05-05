# Changelog

All notable changes to Yuki will be documented in this file.

## [0.1.0] - 2026-05-06

### Added

- **Reproducible session features** - All features from the paper are now implemented:
  - `tools.denied` - Filter out tools from the allowed list
  - `environment` - Declare environment variables in module config
  - `systemPrompt` - Write system prompt to `.yuki/CLAUDE.md`
  - `sandbox` - Module option that maps to `--permission-mode`
  - `mcp.servers` - Generate MCP config in `~/.yuki/settings.json`
  - `lib.mkAfter` composition for system prompt merging

- **Profile composition** - Multiple profiles merge deterministically:
  - `default` - Base tools + REPL
  - `rust` - Rust development with toolchain
  - `review` - Read-only, sandboxed code review

- **CLI rebranding** - All user-facing output now uses "yuki" instead of "claw":
  - `--help` shows `yuki v0.1.0`
  - `--version` shows "Yuki CLI"
  - Error messages reference `yuki`

- **Development environment**:
  - `nix develop` - Dev shell with Rust toolchain
  - `shell.nix` - Fallback for non-flake Nix

### Changed

- mkHarness now passes permission mode based on sandbox settings
- System prompt is written to `.yuki/CLAUDE.md` at session start
- MCP servers are configured via `~/.yuki/settings.json`
- Hardcoded paths removed from mkHarness.nix

### Documentation

- Complete rewrite of README.md with team use cases
- Updated USAGE.md with yuki binary references
- New shell.nix for local development

### Credits

- Built on [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code)
- Inspired by [NixVim](https://github.com/nix-community/nixvim)