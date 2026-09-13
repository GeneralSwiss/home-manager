{ config, pkgs, ... }:

{
  home.homeDirectory = "/Users/nick";

  home.packages = with pkgs; [
    pngpaste               # Paste images from the macOS clipboard to a file
  ];

}
