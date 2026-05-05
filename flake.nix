{
  description = "Yuki - Nix-based Claude Code harness";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      mkHarness = modules:
        import ./lib/mkHarness.nix {
          inherit pkgs modules;
          modulePath = ./modules;
        };
    in
    {
      packages.x86_64-linux = {
        default = mkHarness [ ./profiles/default.nix ];
        rust = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
        review = mkHarness [ ./profiles/default.nix ./profiles/locked-review.nix ];
      };

      lib.mkHarness = mkHarness;

      apps.x86_64-linux = {
        default = flake-utils.lib.mkApp {
          drv = mkHarness [ ./profiles/default.nix ];
          exePath = "/bin/yuki";
        };
        rust = flake-utils.lib.mkApp {
          drv = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
          exePath = "/bin/yuki";
        };
        review = flake-utils.lib.mkApp {
          drv = mkHarness [ ./profiles/default.nix ./profiles/locked-review.nix ];
          exePath = "/bin/yuki";
        };
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          rustfmt
          clippy
          rust-analyzer
          nil
          nixfmt-rfc-style
        ];

        shellHook = ''
          echo "❄️ Yuki dev shell"
          echo "  cd rust      - work on Rust codebase"
          echo "  nix develop  - this shell"
          echo ""
        '';
      };
    };
}