# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Detected stack
- Languages: Rust.
- Build: Nix flake (`flake.nix`)
- Frameworks: none detected from the supported starter markers.

## Verification
- Run Rust verification from repo root: `scripts/fmt.sh --check`; for formatting use `scripts/fmt.sh`. Run Rust clippy/tests from `rust/`: `cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`
- Verify Nix flake: `nix flake check` or `nix eval .#packages.x86_64-linux.default.outPath`

## Repository shape
- `rust/` contains the Rust workspace and active CLI/runtime implementation.
- `src/` contains source files that should stay consistent with generated guidance and tests.
- `tests/` contains validation surfaces that should be reviewed alongside code changes.
- `flake.nix` defines Yuki harness outputs.
- `lib/` contains Nix harness builder (`mkHarness.nix`).
- `modules/` contains Nix module definitions.
- `profiles/` contains harness profile compositions.

## Working agreement
- Prefer small, reviewable changes and keep generated bootstrap files aligned with actual repo workflows.
- Keep shared defaults in `.claude.json`; reserve `.claude/settings.local.json` for machine-local overrides.
- Do not overwrite existing `CLAUDE.md` content automatically; update it intentionally when repo workflows change.