{ nixpkgs, modules }:

let
  eval = nixpkgs.lib.evalModules {
    modules = [ ./modules/default.nix ] ++ modules;
  };

  cfg = eval.config.claudeCode;

  toolchainEnv = nixpkgs.buildEnv {
    name = "yuki-toolchain";
    paths = cfg.toolchain.packages;
  };

  claudeMd = nixpkgs.writeText "CLAUDE.md" cfg.systemPrompt;

  mcpConfigJson = builtins.toJSON {
    mcpServers = cfg.mcp.servers;
  };
  mcpConfig = nixpkgs.writeText "mcp.json" mcpConfigJson;

  sandboxWritable = 
    if cfg.sandbox.writablePaths != [] 
    then builtins.concatStringsSep ":" cfg.sandbox.writablePaths 
    else "/tmp";

in

nixpkgs.writeShellApplication {
  name = "yuki";
  runtimeInputs = cfg.toolchain.packages ++ [ nixpkgs.claude-code ];
  text = ''
    set -e
    TOOLS_ALLOWED=$(''' + builtins.concatStringsSep "," cfg.tools.allowed + ''')
    TOOLS_DENIED=$(''' + builtins.concatStringsSep "," cfg.tools.denied + ''')
    
    export PATH="${toolchainEnv}/bin:$PATH"
    export CLAUDE_MODEL="''' + cfg.model + '''"
    export CLAUDE_TOOLS="$TOOLS_ALLOWED"
    export CLAUDE_TOOLS_DENIED="$TOOLS_DENIED"
    export CLAUDE_SANDBOX="''' + (if cfg.sandbox.enable then "true" else "false") + '''"
    export CLAUDE_SANDBOX_WRITABLE="''' + sandboxWritable + '''"
    export CLAUDE_SANDBOX_NETWORK="''' + (if cfg.sandbox.allowNetwork then "true" else "false") + '''"

    exec claude \
      --model "$CLAUDE_MODEL" \
      --system-prompt-file ${claudeMd} \
      --mcp-config ${mcpConfig} \
      --sandbox "$CLAUDE_SANDBOX" \
      "$@"
  '';
}