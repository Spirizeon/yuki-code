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

  claudeMd = pkgs.writeTextFile {
    name = "CLAUDE.md";
    text = cfg.systemPrompt;
  };

  mcpConfigJson = builtins.toJSON {
    mcpServers = cfg.mcp.servers;
  };
  mcpConfig = pkgs.writeTextFile {
    name = "mcp.json";
    text = mcpConfigJson;
  };

  sandboxWritable = 
    if cfg.sandbox.writablePaths != [] 
    then builtins.concatStringsSep ":" cfg.sandbox.writablePaths 
    else "/tmp";

  toolsAllowed = builtins.concatStringsSep "," cfg.tools.allowed;
  toolsDenied = builtins.concatStringsSep "," cfg.tools.denied;
  sandboxEnabled = if cfg.sandbox.enable then "true" else "false";
  sandboxNetwork = if cfg.sandbox.allowNetwork then "true" else "false";

in

pkgs.runCommand "yuki" {
  inherit toolchainEnv claudeMd mcpConfig;
  buildInputs = [ pkgs.bash ];
} (''
  mkdir -p $out/bin
  cp "$claudeMd" $out/CLAUDE.md
  cp "$mcpConfig" $out/mcp.json

  cat > $out/bin/yuki <<'SCRIPT'
#!${pkgs.stdenv.shell}
set -e

export PATH="${toolchainEnv}/bin:$PATH"
export CLAUDE_TOOLS="${toolsAllowed}"
export CLAUDE_TOOLS_DENIED="${toolsDenied}"
export CLAUDE_SANDBOX="${sandboxEnabled}"
export CLAUDE_SANDBOX_WRITABLE="${sandboxWritable}"
export CLAUDE_SANDBOX_NETWORK="${sandboxNetwork}"

# Check for claude CLI
if ! command -v claude &> /dev/null; then
  echo "Error: claude CLI not found in PATH" >&2
  echo "Install Claude Code or add it to the toolchain in your profile" >&2
  exit 1
fi

exec claude \
  --model ${cfg.model} \
  --system-prompt-file $out/CLAUDE.md \
  --mcp-config $out/mcp.json \
  --sandbox $CLAUDE_SANDBOX \
  "$@"
SCRIPT

  chmod +x $out/bin/yuki
'')