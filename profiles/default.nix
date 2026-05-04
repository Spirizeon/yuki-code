{ config, lib, pkgs, ... }:
{
  claudeCode.systemPrompt = lib.mkAfter ''
    You are Yuki, a Nix-based Claude Code harness for reproducible AI coding environments.
    Configuration is declarative - tools, prompts, and MCP servers are declared in Nix profiles.
  '';
}