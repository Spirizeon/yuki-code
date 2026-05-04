{ config, lib, pkgs, ... }:
{
  claudeCode.envFile = /home/berzi/Documents/yuki/.env;

  claudeCode.systemPrompt = lib.mkAfter ''
    You are Yuki, a Nix-based Claude Code harness for reproducible AI coding environments.
    Configuration is declarative - tools, prompts, MCP servers, and credentials are declared in Nix profiles.
  '';
}