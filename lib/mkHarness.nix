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

  # Compute effective tools: allowed minus denied
  effectiveTools = let
    allowedSet = builtins.foldl' (acc: tool: acc // { ${tool} = true; }) {} cfg.tools.allowed;
    deniedSet = builtins.foldl' (acc: tool: acc // { ${tool} = true; }) {} cfg.tools.denied;
  in builtins.filter (tool: allowedSet.${tool} or false && !(deniedSet.${tool} or false)) cfg.tools.allowed;

  toolsAllowedStr = builtins.concatStringsSep "," effectiveTools;
  modelStr = cfg.model;
  shellPath = pkgs.stdenv.shell;
  envFileVal = if cfg.envFile != null then toString cfg.envFile else "";

  # Determine permission mode from sandbox settings
  permissionMode = if cfg.sandbox.enable then
    if cfg.sandbox.allowNetwork then "workspace-write" else "read-only"
  else "danger-full-access";

  # Generate environment variables string
  envVarsStr = builtins.concatStringsSep "\n" (
    builtins.map (name: "export ${name}=${cfg.environment.${name}};") 
    (builtins.attrNames cfg.environment)
  );

  # System prompt escaped for shell
  systemPromptEscaped = builtins.replaceStrings ["'"] ["'\\''"] cfg.systemPrompt;

  # MCP config JSON
  mcpJson = let
    servers = builtins.mapAttrs (n: v: {
      type = "stdio";
      command = v.command;
      args = v.args;
      env = v.env;
    }) cfg.mcp.servers;
    hasServers = (builtins.length (builtins.attrNames cfg.mcp.servers)) > 0;
  in if hasServers then builtins.toJSON { inherit servers; } else "";

in

pkgs.writeScriptBin "yuki" (
  "#!" + shellPath + "\n" +
  "set -e\n" +
  "export PATH=\"${toolchainEnv}/bin:$PATH\"\n" +
  "export CLAUDE_TOOLS=\"${toolsAllowedStr}\"\n" +
  envVarsStr + "\n" +
  "if [ -n \"${envFileVal}\" ] && [ -f \"${envFileVal}\" ]; then\n" +
  "  set -a\n" +
  "  source \"${envFileVal}\"\n" +
  "  set +a\n" +
  "fi\n" +
  "if [ -n \"${systemPromptEscaped}\" ]; then\n" +
  "  mkdir -p .yuki\n" +
  "  echo -n '${systemPromptEscaped}' > .yuki/CLAUDE.md\n" +
  "fi\n" +
  (if mcpJson == "" then "" else
  "cat > \"$HOME/.yuki/settings.json\" << 'MCPEOF'\n" + mcpJson + "\nMCPEOF\n") +
  "YUKI_BIN=\n" +
  "for p in ./rust/target/release/yuki /run/current-system/sw/bin/yuki; do\n" +
  "  if [ -x \"$p\" ]; then YUKI_BIN=\"$p\"; fi\n" +
  "done\n" +
  "[ -z \"$YUKI_BIN\" ] && command -v yuki && YUKI_BIN=yuki\n" +
  "[ -z \"$YUKI_BIN\" ] && echo \"Error: yuki CLI not found\" && exit 1\n" +
  "MODEL=\"${modelStr}\"\n" +
  "case $MODEL in claude-sonnet-4-20250514) MODEL=sonnet ;; esac\n" +
  "exec \"$YUKI_BIN\" --model \"$MODEL\" --permission-mode \"${permissionMode}\" \"$@\"\n"
)