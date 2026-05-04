{ config, lib, pkgs, ... }:

let
  mkToolOption = description:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = description;
    };

in
{
  options.claudeCode = {
    enable = lib.mkEnableOption "Yuki - Nix-based Claude Code harness";

    model = lib.mkOption {
      type = lib.types.str;
      default = "claude-sonnet-4-20250514";
      description = "Model to use for Claude API";
    };

    tools = lib.mkOption {
      type = lib.types.submodule {
        options = {
          allowed = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "bash" "read" "write" "edit" "grep" "glob" "websearch" "webfetch" "agent" "todo" "notebook" ];
            description = "Tools Claude is permitted to use";
          };
          denied = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Tools explicitly blocked";
          };
        };
      };
      description = "Tool permissions";
      default = {};
    };

    toolchain = lib.mkOption {
      type = lib.types.submodule {
        options = {
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Packages available in PATH (realized hermetically)";
          };
        };
      };
      description = "Development toolchain";
      default = {};
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables injected into session";
      example = { RUST_BACKTRACE = "1"; CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse"; };
    };

    systemPrompt = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "System prompt fragment (use lib.mkAfter to append in profiles)";
    };

    mcp = lib.mkOption {
      type = lib.types.submodule {
        options = {
          servers = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                command = lib.mkOption {
                  type = lib.types.str;
                  description = "Path to MCP server binary";
                };
                args = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                  description = "Command-line arguments";
                };
                env = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = {};
                  description = "Environment variables";
                };
              };
            });
            default = {};
            description = "MCP server configurations";
          };
        };
      };
      description = "MCP server configuration";
      default = {};
    };

    sandbox = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable sandbox isolation";
          };
          allowNetwork = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow network access in sandbox";
          };
          writablePaths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "/tmp" ];
            description = "Paths writable within sandbox";
          };
        };
      };
      description = "Sandbox isolation settings";
      default = {};
    };
  };

  config.claudeCode.enable = lib.mkDefault true;
}