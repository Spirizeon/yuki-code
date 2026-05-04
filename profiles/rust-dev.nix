{ config, lib, pkgs, ... }:
{
  claudeCode.toolchain.packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    clippy
    cargo-expand
    cargo-tree
    fmt
    rustfmt
  ];

  claudeCode.environment = {
    RUST_BACKTRACE = "1";
    RUSTDOC_HTML_REMOTE_URLS = "https://doc.rust-lang.org/${pkgs.lib.version}";
  };

  claudeCode.systemPrompt = lib.mkAfter ''
    Working in a Rust project. Use cargo clippy, cargo build, and cargo test before marking tasks complete.
    Run `cargo tree -i` to see dependency sources.
  '';
}