# main flake.nix
{
  description = "Main configuration applying system-specific home-config-flake artifacts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixvim-neovim = { url = "github:GeneralSwiss/nixvim-neovim"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, home-manager, nixvim-neovim, ... }:
    let
      makePkgs = system: import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: { neovim = nixvim-neovim.packages.${system}.default; })
        ];
      };    
    in {
      homeConfigurations = {
      "nick@Nicks-MacBook-Pro" = home-manager.lib.homeManagerConfiguration {
        pkgs = makePkgs "x86_64-darwin";
        modules = [
          ./home.nix
          ./darwin.nix
        ];
      };
      "nick@NFPC" = home-manager.lib.homeManagerConfiguration {
        pkgs = makePkgs "x86_64-linux";
        modules = [
          ./home.nix
          ./linux.nix
        ];
      };
    };
  };
}
