{ config, pkgs, ... }:

{
  home.homeDirectory = "/Users/nick";

  home.packages = with pkgs; [
    pngpaste               # Paste images from the macOS clipboard to a file
  ];

  # Homebrew still owns a few GUI casks and macOS-only formulae, so its shell
  # environment has to be on PATH. Apple Silicon installs to /opt/homebrew;
  # Intel used /usr/local. Guarding on the path keeps one file valid for both.
  home.sessionVariablesExtra = ''
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  '';
}
