# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Detected stack
- Languages: Rust.
- Frameworks: none detected from the supported starter markers.

## Verification
- From the repository root, run Rust formatting with `scripts/fmt.sh` (or `scripts/fmt.sh --check` for CI-style checks). From this `rust/` directory, the equivalent command is `../scripts/fmt.sh`. Root-level `cargo fmt --manifest-path rust/Cargo.toml` is not the supported formatting command.
- From this `rust/` directory, run Rust verification with `cargo clippy --workspace --all-targets -- -D warnings` and `cargo test --workspace`.

## Repository shape
- `crates/rusty-claude-cli/` contains the main CLI binary (`yuki`).
- Use `yuki` as the command name instead of `claw`.

## Working agreement
- Prefer small, reviewable changes and keep generated bootstrap files aligned with actual repo workflows.
- Keep shared defaults in `.claude.json`; reserve `.claude/settings.local.json` for machine-local overrides.
- Do not overwrite existing `CLAUDE.md` content automatically; update it intentionally when repo workflows change.