# Yuki

<p align="center">
  <a href="https://github.com/spirizeon/yuki">spirizeon/yuki</a>
  ·
  <a href="./USAGE.md">Usage</a>
  ·
  <a href="./rust/README.md">Rust workspace</a>
  ·
  <a href="./PARITY.md">Parity</a>
  ·
  <a href="./ROADMAP.md">Roadmap</a>
  ·
  <a href="https://discord.gg/5TUQKqFWd">UltraWorkers Discord</a>
</p>

<p align="center">
  <a href="https://star-history.com/#spirizeon/yuki&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=spirizeon/yuki&type=Date&theme=dark" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=spirizeon/yuki&type=Date" />
      <img alt="Star history for spirizeon/yuki" src="https://api.star-history.com/svg?repos=spirizeon/yuki&type=Date" width="600" />
    </picture>
  </a>
</p>

<p align="center">
  .     .--. 
 .-.          .-        .'|     |__| 
  \ \        / /      .'  |     .--. 
   \ \      / /      <    |     |  | 
    \ \    / /_    _  |   | ____|  | 
     \ \  / /| '  / | |   | \ .'|  | 
      \ `  /.' | .' | |   |/  . |  | 
       \  / /  | /  | |    /\  \|__| 
       / / |   `'.  | |   |  \  \    
   |`-' /  '   .'|  '/'    \  \  \   
    '..'    `-'  `--''------'  '---' 
</p>

Yuki is a high-performance Rust CLI agent harness that connects to Claude (Anthropic), OpenAI, xAI, and other model providers. It provides an interactive REPL, session persistence, tool execution, MCP server integration, and a plugin system.

> [!IMPORTANT]
> Start with [`USAGE.md`](./USAGE.md) for build, auth, CLI, session, and parity-harness workflows. Make `yuki doctor` your first health check after building, use [`rust/README.md`](./rust/README.md) for crate-level details, read [`PARITY.md`](./PARITY.md) for the current Rust-port checkpoint, and see [`docs/container.md`](./docs/container.md) for the container-first workflow.

## Current repository shape

- **`rust/`** — canonical Rust workspace and the `yuki` CLI binary
- **`USAGE.md`** — task-oriented usage guide for the current product surface
- **`PARITY.md`** — Rust-port parity status and migration notes
- **`ROADMAP.md`** — active roadmap and cleanup backlog
- **`PHILOSOPHY.md`** — project intent and system-design framing
- **`src/` + `tests/`** — companion Python/reference workspace and audit helpers; not the primary runtime surface

## Quick start

```bash
# 1. Clone and build
git clone https://github.com/spirizeon/yuki
cd yuki/rust
cargo build --workspace

# 2. Set your API key (Anthropic API key — not a Claude subscription)
export ANTHROPIC_API_KEY="sk-ant-..."

# 3. Verify everything is wired correctly
./target/debug/yuki doctor

# 4. Run a prompt
./target/debug/yuki prompt "say hello"
```

> [!NOTE]
> **Windows (PowerShell):** use `.\target\debug\yuki.exe` or run `cargo run -- prompt "say hello"` to skip the path lookup.

### Windows setup

**PowerShell is a supported Windows path.** Use whichever shell works for you. The common onboarding issues on Windows are:

1. **Install Rust first** — download from <https://rustup.rs/> and run the installer. Close and reopen your terminal when it finishes.
2. **Verify Rust is on PATH:**
   ```powershell
   cargo --version
   ```
   If this fails, reopen your terminal or run the PATH setup from the Rust installer output, then retry.
3. **Clone and build** (works in PowerShell, Git Bash, or WSL):
   ```powershell
   git clone https://github.com/spirizeon/yuki
   cd yuki/rust
   cargo build --workspace
   ```
4. **Run** (PowerShell — note `.exe` and backslash):
   ```powershell
   $env:ANTHROPIC_API_KEY = "sk-ant-..."
   .\target\debug\yuki.exe prompt "say hello"
   ```

**Git Bash / WSL** are optional alternatives, not requirements. If you prefer bash-style paths (`/c/Users/you/...` instead of `C:\Users\you\...`), Git Bash (ships with Git for Windows) works well.

## Post-build: locate the binary and verify

After running `cargo build --workspace`, the `yuki` binary is built but **not** automatically installed to your system.

### Binary location

After `cargo build --workspace` in `yuki/rust/`:

- **macOS/Linux:** `rust/target/debug/yuki`
- **Windows:** `rust/target/debug/yuki.exe`

- **Release build:** `rust/target/release/yuki` or `yuki.exe`

### Verify the build succeeded

```bash
# macOS/Linux (debug build)
./rust/target/debug/yuki --help
./rust/target/debug/yuki doctor

# Windows PowerShell (debug build)
.\rust\target\debug\yuki.exe --help
.\rust\target\debug\yuki.exe doctor
```

### Optional: Add to PATH

**Option 1: Symlink (macOS/Linux)**
```bash
ln -s $(pwd)/rust/target/debug/yuki /usr/local/bin/yuki
```

**Option 2: Use `cargo install`**
```bash
cd rust
cargo install --path . --force
```

**Option 3: Update shell profile**

Add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$(pwd)/rust/target/debug:$PATH"
```

> [!NOTE]
> **Auth:** Yuki requires an **API key** (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc.) — Claude subscription login is not a supported auth path.

Run the workspace test suite:
```bash
cd rust
cargo test --workspace
```

## Documentation map

- [`USAGE.md`](./USAGE.md) — quick commands, auth, sessions, config, parity harness
- [`rust/README.md`](./rust/README.md) — crate map, CLI surface, features, workspace layout
- [`PARITY.md`](./PARITY.md) — parity status for the Rust port
- [`rust/MOCK_PARITY_HARNESS.md`](./rust/MOCK_PARITY_HARNESS.md) — deterministic mock-service harness details
- [`ROADMAP.md`](./ROADMAP.md) — active roadmap and open cleanup work
- [`PHILOSOPHY.md`](./PHILOSOPHY.md) — why the project exists and how it is operated

## Ecosystem

Yuki is built in the open alongside the broader UltraWorkers toolchain:

- [clawhip](https://github.com/Yeachan-Heo/clawhip)
- [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)
- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex)
- [UltraWorkers Discord](https://discord.gg/5TUQKqFWd)

## Ownership / affiliation disclaimer

- This repository does **not** claim ownership of the original Claude Code source material.
- This repository is **not affiliated with, endorsed by, or maintained by Anthropic**.