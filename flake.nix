{
  description = "Yuki - Nix-based Claude Code harness";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      mkHarness = modules:
        import ./lib/mkHarness.nix {
          inherit nixpkgs;
          inherit modules;
        };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = mkHarness [ ./profiles/default.nix ];
          rust = mkHarness [ ./profiles/default.nix ./profiles/rust-dev.nix ];
          review = mkHarness [ ./profiles/default.nix ./profiles/locked-review.nix ];
        };

        lib = {
          mkHarness = mkHarness;
        };

        apps = {
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
      }
    );
}