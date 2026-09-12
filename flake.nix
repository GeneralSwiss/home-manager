{
  description = "Reproducible user environment: packages via Nix, behaviour via tracked dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # One helper instead of a copy-pasted block per machine: adding a box is a
      # single line below rather than eight, and every machine is guaranteed to
      # get home.nix rather than drifting by omission.
      mkHome = { system, platformModule }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [ ./home.nix platformModule ];
        };
    in
    {
      homeConfigurations = {
        # Linux desktop
        "nick@ubuntu" = mkHome {
          system = "x86_64-linux";
          platformModule = ./linux.nix;
        };

        # macOS. Apple Silicon is the default; the Intel entry stays for older
        # hardware. The previous revision declared only x86_64-darwin, which
        # would have failed to evaluate on any M-series machine.
        "nick@mac" = mkHome {
          system = "aarch64-darwin";
          platformModule = ./darwin.nix;
        };

        "nick@mac-intel" = mkHome {
          system = "x86_64-darwin";
          platformModule = ./darwin.nix;
        };
      };
    };
}
