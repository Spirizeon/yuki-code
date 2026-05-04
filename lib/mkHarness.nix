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

  toolsAllowedStr = builtins.concatStringsSep "," cfg.tools.allowed;
  modelStr = cfg.model;
  shellPath = pkgs.stdenv.shell;
  envFileVal = if cfg.envFile != null then toString cfg.envFile else "";

in

pkgs.writeScriptBin "yuki" (
  "#!" + shellPath + "\n" +
  "set -e\n" +
  "export PATH=\"${toolchainEnv}/bin:$PATH\"\n" +
  "export CLAUDE_TOOLS=\"${toolsAllowedStr}\"\n" +
  
  "# Load .env file if configured\n" +
  "if [ -n \"${envFileVal}\" ] && [ -f \"${envFileVal}\" ]; then\n" +
  "  set -a\n" +
  "  source \"${envFileVal}\"\n" +
  "  set +a\n" +
  "fi\n" +
  
  "YUKI_BIN=\n" +
  "for p in /home/berzi/Documents/yuki/rust/target/release/yuki ./rust/target/release/yuki /run/current-system/sw/bin/yuki; do\n" +
  "  if [ -x \"$p\" ]; then YUKI_BIN=\"$p\"; fi\n" +
  "done\n" +
  "[ -z \"$YUKI_BIN\" ] && command -v yuki && YUKI_BIN=yuki\n" +
  "[ -z \"$YUKI_BIN\" ] && echo \"Error: yuki CLI not found\" && exit 1\n" +
  "MODEL=\"${modelStr}\"\n" +
  "case $MODEL in claude-sonnet-4-20250514) MODEL=sonnet ;; esac\n" +
  "exec \"$YUKI_BIN\" --model \"$MODEL\" \"$@\"\n"
)