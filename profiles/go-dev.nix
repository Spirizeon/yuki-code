{ config, lib, pkgs, ... }:

{
  claudeCode.toolchain.packages = with pkgs; [
    go
    go-tools
    gopls
  ];

  claudeCode.environment = {
    GO111MODULE = "on";
    GOPROXY = "https://proxy.golang.org,direct";
  };

  claudeCode.systemPrompt = lib.mkAfter ''
    Working in a Go project. Run go build, go vet, and go test before marking tasks complete.
    Use gofmt for formatting.
  '';
}