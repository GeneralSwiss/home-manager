{ config, pkgs, ... }:

{
  home.homeDirectory = "/home/nick";

  # Linux-only packages. Terminal emulator config is deliberately absent: the
  # GNOME terminal profile lives in dconf, which does not travel to macOS.
  home.packages = with pkgs; [
    xclip                  # Clipboard bridge for X11 (`git apply` from clipboard, nvim yank)
  ];
}
