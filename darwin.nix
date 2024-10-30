{ config, pkgs, ... }:

{
  home.homeDirectory = "/Users/nick";

  # Install Nix packages
  home.packages = with pkgs; [
    pngpaste
  ];
  programs.fish.shellInitLast = "eval \"$(/usr/local/bin/brew shellenv)\""; 
}
