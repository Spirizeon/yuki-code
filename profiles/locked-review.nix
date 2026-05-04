{ ... }:
{
  claudeCode.tools.allowed = [ "read" "grep" "glob" "websearch" "webfetch" ];
  claudeCode.tools.denied = [ "write" "edit" "bash" "execute" ];
  claudeCode.sandbox.enable = true;
  claudeCode.sandbox.allowNetwork = false;
  claudeCode.sandbox.writablePaths = [ ];

  claudeCode.systemPrompt = lib.mkAfter ''
    Read-only review session. Do not modify any files. Use grep and glob to understand the codebase.
    Provide analysis and suggestions, but never write code changes.
  '';
}