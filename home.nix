{ config, pkgs, ... }:

let
  # Absolute path to the dotfiles tracked in this repository.
  #
  # `mkOutOfStoreSymlink` (below) needs a path that exists on the machine at
  # activation time rather than a copy in the Nix store, so it cannot be a
  # relative path literal.
  dotfiles = "${config.home.homeDirectory}/.config/home-manager/dotfiles";

  # Link a config file so edits take effect immediately.
  #
  # The default `home.file.<n>.source = ./some/file` copies the file into
  # /nix/store, which is read-only: every experiment would then need a
  # `home-manager switch` before it could even be tried. `mkOutOfStoreSymlink`
  # points at the working copy in this repo instead, so the file stays live and
  # editable while remaining the single versioned source of truth.
  #
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.file._name_.source
  live = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # Basic Home Manager configuration
  home.username = "nick";
  home.homeDirectory = pkgs.lib.mkDefault "/home/nick";  # overridden per platform

  # First activation is on the 26.05 release. This pins migration semantics and
  # should not be bumped casually -- it is not a "current version" field.
  home.stateVersion = "26.05";

  # Packages installed on every machine, Linux and macOS alike. This is the half
  # of reproducibility that a dotfile manager alone cannot give: same tools, same
  # versions, both boxes.
  home.packages = with pkgs; [
    # Toolchain
    gnumake
    gcc
    rustup                 # Rust toolchain installer
    openssl
    pkg-config
    nodejs_22
    jdk21
    go

    # Shell environment
    zsh                    # Login shell; configured by dotfiles/zsh/zshrc
    starship               # Prompt
    zoxide                 # Directory jumping; supersedes autojump
    fzf                    # Fuzzy finder
    tmux                   # Terminal multiplexer

    # Editor
    neovim                 # Configured by the dotfiles/nvim submodule

    # Language servers and formatters.
    #
    # These exist here rather than being left to Mason for a specific reason:
    # Mason downloads prebuilt binaries linked against the *host* glibc, so on
    # an older distribution they fail exactly the way a stock neovim does.
    # Nix ships its own glibc in the store, so these run anywhere Nix runs.
    # dotfiles/nvim/lua/plugins/nix-lsp.lua detects them on PATH and tells
    # Mason to stand down for those servers.
    lua-language-server
    marksman                       # Markdown
    taplo                          # TOML
    vscode-langservers-extracted   # html/css/json/eslint
    astro-language-server
    stylua                         # Lua formatter
    shfmt                          # Shell formatter
    markdownlint-cli2
    tree-sitter

    # CLI replacements referenced by the shell aliases in dotfiles/zsh/zshrc
    lsd                    # ls
    dust                   # du
    ripgrep                # grep
    fd                     # find

    # Git and friends
    git
    gh                     # GitHub CLI
    lazygit                # Git TUI -- aliased to `lg`
    tig

    # Misc utilities
    jq
    tldr
    zola
  ];

  # Environment variables for the session
  home.sessionVariables = {
    EDITOR = "nvim";
    CLICOLOR = 1;
    # Rust crates that link against OpenSSL need these to find the Nix copy.
    OPENSSL_LIB_DIR = "${pkgs.lib.getLib pkgs.openssl}/lib";
    OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
  };

  # The dotfiles themselves.
  #
  # Note there is deliberately no `programs.zsh.enable` or `programs.tmux.enable`
  # below: those modules *generate* ~/.zshrc and ~/.config/tmux/tmux.conf, which
  # would collide with the files linked here. Behaviour is owned by one layer
  # only, and for these three tools that layer is the checked-in file.
  home.file = {
    ".zshrc".source = live "zsh/zshrc";
    ".tmux.conf".source = live "tmux/tmux.conf";
  };

  xdg.configFile = {
    "nvim".source = live "nvim";
  };

  # Enable Home Manager management of itself
  programs.home-manager.enable = true;

  # Program configurations for tools whose dotfiles are NOT tracked literally
  # above -- here Nix is the single source of truth and there is no conflict.
  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];  # colorized man pages
    };

    git = {
      enable = true;
      userEmail = "nicolas.farrier@gmail.com";
      userName = "GeneralSwiss";
      diff-so-fancy.enable = true;
      ignores = [ "*~" "*.swp" ];
      aliases = {
        lg = "log --oneline --graph --decorate --all --pretty=format:'%C(auto)%h %d %s %C(green)(%an, %ar)'";
      };
    };

    jq.enable = true;

    lsd = {
      enable = true;
      settings = {
        date = "relative";
      };
    };
  };
}
