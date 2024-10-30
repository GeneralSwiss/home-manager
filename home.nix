{ config, pkgs, ... }:

{
  # Basic configuration
  home.username = "nick";
  home.homeDirectory = "/Users/nick";
  home.stateVersion = "24.05";

  # Install Nix packages
  home.packages = with pkgs; [
    rustup
    dust
    ripgrep
    fzf
    git
    tig
    jq
    navi
    lf
    watson
    tldr
    fd
    ack
    nodejs_22
    buku
    autojump
    taskwarrior3
    pngpaste
    lsd
    jdk21
    fish
    starship
    neovim
    gh
    tmux
    zola
  ];

  # Configure session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    CLICOLOR = 1;
  };

  # Aliases for shells
  home.shellAliases = {
    man = "batman";
    cat = "bat";
    du = "dust";
  };

  # Enable Home Manager management of itself
  programs.home-manager.enable = true;

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
    };
    git = {
      enable = true;
      diff-so-fancy.enable = true;
      ignores = [ "*~" "*.swp" ];
      aliases = {
        lg = "log --graph --full-history --all --pretty=format:'%h%x09%C(cyan)(%cr)%Creset - %<(20,trunc)%C(magenta)%an%x09%C(yellow)%d%Creset%x20%s'";
      };
    };
    autojump = {
      enable = true;
      enableFishIntegration = true;
    };
    jq.enable = true;
    navi = {
      enable = true;
      enableFishIntegration = true;
    };
    fish = {
      enable = true;
      shellAliases = {
        vim = "nvim";
        man = "batman";
        cat = "bat";
      };
      shellInitLast = "eval \"$(/usr/local/bin/brew shellenv)\"";
    };
    lsd = {
      enable = true;
      enableAliases = true;
      settings = {
        date = "relative";
      };
    };
    starship.enable = true;
    tmux = {
      enable = true;
      mouse = true;
      terminal = "screen-256color";
      baseIndex = 1;
      clock24 = true;
      plugins = with pkgs; [
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
      ];
      extraConfig = "setenv -g EDITOR nvim\n";
    };
  };
}
