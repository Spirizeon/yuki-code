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

in

pkgs.writeScriptBin "yuki" (
  "#!" + shellPath + "\n" +
  "set -e\n" +
  "export PATH=\"${toolchainEnv}/bin:$PATH\"\n" +
  "export CLAUDE_TOOLS=\"${toolsAllowedStr}\"\n" +
  "CLAUDE_BIN=\n" +
  "for p in /home/berzi/Documents/yuki/rust/target/release/claw ./rust/target/release/claw /run/current-system/sw/bin/claude; do\n" +
  "  if [ -x \"$p\" ]; then CLAUDE_BIN=\"$p\"; fi\n" +
  "done\n" +
  "[ -z \"$CLAUDE_BIN\" ] && command -v claude && CLAUDE_BIN=claude\n" +
  "[ -z \"$CLAUDE_BIN\" ] && echo \"Error: claude not found\" && exit 1\n" +
  "MODEL=\"${modelStr}\"\n" +
  "case $MODEL in claude-sonnet-4-20250514) MODEL=sonnet ;; esac\n" +
  "exec \"$CLAUDE_BIN\" --model \"$MODEL\" \"$@\"\n"
)