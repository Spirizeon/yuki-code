{ config, lib, pkgs, ... }:
{
  claudeCode.toolchain.packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    clippy
    cargo-expand
    rustfmt
  ];

  claudeCode.environment = {
    RUST_BACKTRACE = "1";
  };

  claudeCode.systemPrompt = lib.mkAfter ''
    Working in a Rust project. Use cargo clippy, cargo build, and cargo test before marking tasks complete.
  '';
}