{ pkgs, modules, modulePath }:

let
  eval = pkgs.lib.evalModules {
    modules = [ "${modulePath}/default.nix" ] ++ modules;
    specialArgs = { inherit pkgs; };
  };

  cfg = eval.config.claudeCode;

  toolchainEnv = pkgs.buildEnv {
    name = "yuki-toolchain";
    paths = cfg.toolchain.packages;
  };

  claudeMd = pkgs.writeText "CLAUDE.md" cfg.systemPrompt;

  mcpConfigJson = builtins.toJSON {
    mcpServers = cfg.mcp.servers;
  };
  mcpConfig = pkgs.writeText "mcp.json" mcpConfigJson;

  sandboxWritable = 
    if cfg.sandbox.writablePaths != [] 
    then builtins.concatStringsSep ":" cfg.sandbox.writablePaths 
    else "/tmp";

  toolsAllowed = builtins.concatStringsSep "," cfg.tools.allowed;
  toolsDenied = builtins.concatStringsSep "," cfg.tools.denied;
  sandboxEnabled = if cfg.sandbox.enable then "true" else "false";
  sandboxNetwork = if cfg.sandbox.allowNetwork then "true" else "false";

  wrapper = pkgs.writeText "yuki-wrapper.sh" ''
    #!${pkgs.stdenv.shell}
    set -e

    export PATH="${toolchainEnv}/bin:$PATH"
    export CLAUDE_MODEL="${cfg.model}"
    export CLAUDE_TOOLS="${toolsAllowed}"
    export CLAUDE_TOOLS_DENIED="${toolsDenied}"
    export CLAUDE_SANDBOX="${sandboxEnabled}"
    export CLAUDE_SANDBOX_WRITABLE="${sandboxWritable}"
    export CLAUDE_SANDBOX_NETWORK="${sandboxNetwork}"

    exec claude \
      --model "$CLAUDE_MODEL" \
      --system-prompt-file ${claudeMd} \
      --mcp-config ${mcpConfig} \
      --sandbox "$CLAUDE_SANDBOX" \
      "$@"
  '';

in

pkgs.stdenv.mkDerivation {
  name = "yuki";
  pname = "yuki";
  version = "0.1.0";

  builder = pkgs.stdenv.shell;

  args = [
    "-c"
    ''
      mkdir -p $out/bin
      cp ${wrapper} $out/bin/yuki
      chmod +x $out/bin/yuki
    ''
  ];

  shell = pkgs.stdenv.shell;
}