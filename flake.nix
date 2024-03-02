{
  description = "Home Manager configuration of nick";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    menvim = {
     url = "github:GeneralSwiss/me-nvim";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, flake-utils, nixpkgs, home-manager, menvim, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      menvim-overlay = self: super: { neovim = self.callPackge menvim {}; };
      pkgs = import nixpkgs { inherit system; overlays = [ menvim-overlay ]; };
    in {
      homeConfigurations."nick" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
