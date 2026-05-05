# Yuki Development Guide

This guide is for developers who want to contribute to Yuki.

## Prerequisites

- Nix with flakes enabled
- Git
- GitHub account (for pushing changes)

## Setting Up Your Development Environment

### Option 1: Nix Develop (Recommended)

```bash
# Clone the repository
git clone https://github.com/Spirizeon/yuki-code
cd yuki-code

# Enter the dev shell with Rust toolchain
nix develop
```

This provides:
- Rust toolchain (rustc, cargo, rustfmt, clippy, rust-analyzer)
- Nil (Nix LSP)
- Nixfmt for formatting Nix files

### Option 2: Shell.nix (Fallback)

If you cannot use flakes:

```bash
nix-shell shell.nix
```

## Building Yuki

### Build the Rust CLI

```bash
cd rust
cargo build --release
```

The binary will be at `rust/target/release/yuki`.

### Build Nix Profiles

```bash
# Build default profile
nix build .#default

# Build rust profile  
nix build .#rust

# Build review profile
nix build .#review
```

Built profiles appear in `./result/bin/yuki`.

## Running Tests

### Rust Tests

```bash
cd rust

# Run all tests
cargo test --release

# Run only library tests
cargo test --release --lib

# Run only integration tests
cargo test --release --test '*'

# Run clippy lints
cargo clippy --release --workspace --all-targets -- -D warnings
```

### Nix Tests

```bash
# Build all profiles (validation)
nix build .#default
nix build .#rust
nix build .#review

# Test dev shell
nix develop --command echo "works"

# Test shell.nix fallback
nix-shell shell.nix --command echo "works"

# Check Nix formatting
nix fmt
```

## Making Changes

### 1. Create a Feature Branch

```bash
git checkout -b feature/my-new-feature
```

### 2. Make Your Changes

- Rust code lives in `rust/crates/`
- Nix modules live in `modules/`
- Profiles live in `profiles/`
- Documentation lives in `docs/md/`

### 3. Test Your Changes

Build and run tests before committing:

```bash
# Build
cargo build --release
nix build .#default

# Run tests
cargo test --release
```

### 4. Update Documentation

If your change affects users, update the relevant docs:

- `README.md` - Main user-facing documentation
- `docs/md/SKILL.md` - Module system reference
- `docs/md/USAGE.md` - CLI reference
- `docs/md/CHANGELOG.md` - Release notes

### 5. Commit Your Changes

```bash
# Stage your changes
git add -A

# Write a descriptive commit message
git commit -m "feat: add new feature

- Added X to support Y
- Updated documentation
- Added tests"

# Or use conventional commits
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug in X"
git commit -m "docs: update readme"
git commit -m "chore: cleanup"
```

### 6. Push and Create PR

```bash
git push -u origin feature/my-new-feature
# Then create PR via GitHub UI
```

## Code Style

### Rust

- Run `cargo fmt` before committing
- Run `cargo clippy` to catch issues
- Follow existing code patterns in the codebase

### Nix

- Use `nixfmt` or `nixfmt-rfc-style` for formatting
- Keep modules focused and composable

## Common Tasks

### Add a New Profile

1. Create `profiles/my-profile.nix`
2. Define module options
3. Add to `flake.nix` outputs:

```nix
packages.x86_64-linux.my-profile = mkHarness [ ./profiles/my-profile.nix ];
```

### Add a New Module Option

1. Edit `modules/default.nix`
2. Define the option with type and defaults
3. Use in `lib/mkHarness.nix`

### Add a New CLI Command

1. Edit `rust/crates/rusty-claude-cli/src/main.rs`
2. Add command parsing in the CLI handler
3. Test with `./rust/target/release/yuki --help`

## Troubleshooting

### "command not found: yuki" after build

The harness script looks for the binary in these locations:
1. `./rust/target/release/yuki` (local development)
2. `/run/current-system/sw/bin/yuki` (NixOS system path)
3. Any `yuki` in PATH

If you built with `cargo build --release`, the binary should be found.

### Nix build fails

Check the Nix flake is valid:
```bash
nix flake check
nix flake show
```

### Rust compilation errors

Make sure you have the right Rust version:
```bash
rustc --version  # Should show stable
cargo --version
```

## CI/CD

GitHub Actions runs on every push:

- **Rust CI**: `cargo fmt`, `cargo test`, `cargo clippy`
- **Nix CI**: Build profiles, test dev shell, test yuki binary

All tests must pass before merging to main.

## Release Process

1. Update `CHANGELOG.md` with new version
2. Create git tag:
   ```bash
   git tag -a v0.x.0 -m "Release v0.x.0"
   ```
3. Push with tags:
   ```bash
   git push --follow-tags
   ```
4. Create GitHub release with `gh release create v0.x.0`

## Getting Help

- Open an issue: https://github.com/Spirizeon/yuki-code/issues
- Check existing docs: `docs/md/`
- Look at CLAUDE.md for project context