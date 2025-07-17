{ config, pkgs, ... }:

{
  # Basic Home Manager configuration
  home.username = "nick";                     # Sets the username for this Home Manager configuration
  home.stateVersion = "24.05";                # Sets the Home Manager state version for compatibility

  # Install Nix packages for the user's environment
  home.packages = with pkgs; [
    gnumake                # GNU Make, typically included in stdenv but added here for user shell access
    gcc                    # GCC compiler, also often included in stdenv
    rustup                 # Rust toolchain installer
    openssl                # OpenSSL libraries for secure networking
    pkg-config             # Package config tool to locate libraries
    dust                   # Disk usage tool, modern alternative to `du`
    ripgrep                # Fast recursive search tool, similar to `grep`
    fzf                    # Command-line fuzzy finder
    git                    # Version control system
    tig                    # Text-mode interface for Git repositories
    jq                     # Command-line JSON processor
    navi                   # Interactive command cheat-sheet tool
    lf                     # Terminal file manager
    watson                 # Command-line time-tracking tool
    tldr                   # Simplified man pages
    fd                     # Simple and fast alternative to `find`
    ack                    # Tool for searching source code
    nodejs_22              # Node.js runtime, version 22
    buku                   # CLI bookmark manager
    autojump               # Directory navigation tool based on frequently visited directories
    taskwarrior3           # Command-line task manager
    lsd                    # Modern replacement for `ls` with better formatting
    jdk21                  # Java Development Kit, version 21
    fish                   # Friendly interactive shell
    starship               # Customizable shell prompt
    neovim                 # Modernized Vim text editor
    gh                     # GitHub CLI tool for interacting with GitHub
    tmux                   # Terminal multiplexer for managing multiple sessions
    zola                   # Static site generator
    go                     # GoLang
    lazygit                # Git TUI
  ];

  # Environment variables for the session
  home.sessionVariables = {
    EDITOR = "nvim";                             # Sets Neovim as the default editor
    CLICOLOR = 1;                                # Enables color output in CLI
    # OPENSSL_DIR = "${pkgs.openssl}";         # Specifies OpenSSL directory path
    OPENSSL_LIB_DIR = "${pkgs.lib.getLib pkgs.openssl}/lib"; # Sets library directory for OpenSSL
    OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include"; # Sets include directory for OpenSSL headers
    # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig"; # Path for `pkg-config` to find OpenSSL configs
  };

  # Define aliases to make common CLI commands more user-friendly
  home.shellAliases = {
    man = "batman";  # Use `batman` (colorized man pages) instead of `man`
    cat = "bat";     # Use `bat` (syntax-highlighted `cat`) for file viewing
    du = "dust";     # Use `dust` as a modern, faster alternative to `du`
  };

  # Enable Home Manager management of itself, allowing automatic updates and changes
  programs.home-manager.enable = true;

  # Individual program configurations
  programs = {

    # Configure bat (a cat alternative with syntax highlighting)
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];  # Adds `batman` for viewing man pages with syntax highlighting
    };

    # Git configuration
    git = {
      enable = true;
      userEmail = "nicolas.farrier@gmail.com";       # Set default email for Git commits
      userName = "GeneralSwiss";                     # Set default username for Git commits
      diff-so-fancy.enable = true;                   # Enable diff-so-fancy for improved Git diffs
      ignores = [ "*~" "*.swp" ];                    # Set default ignores for temporary and swap files
      aliases = {
        lg = "log --oneline --graph --decorate --all --pretty=format:'%C(auto)%h %d %s %C(green)(%an, %ar)'"; 
        # Adds an alias for a compact, visual Git log view with author and time information
      };
    };

    # Autojump configuration
    autojump = {
      enable = true;
      enableFishIntegration = true;  # Enables autojump for Fish shell
    };

    # jq configuration
    jq.enable = true;  # Enable jq for JSON processing

    # navi configuration (command-line cheat-sheet tool)
    navi = {
      enable = true;
      enableFishIntegration = true;  # Enables navi's integration in Fish shell
    };

    # Fish shell configuration
    fish = {
      enable = true;
      shellAliases = {
        vim = "nvim";         # Set `vim` command to open Neovim
        man = "batman";       # Use `batman` for colorized man pages
        cat = "bat";          # Use `bat` for syntax-highlighted file viewing
      };
      plugins = [
        {
          name = "nix-env";   # Adds a plugin for Fish shell for managing Nix packages
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
          };
        }
      ];
    };

    # lsd configuration (modern alternative to ls)
    lsd = {
      enable = true;
      enableFishIntegration = true;  # Enable standard aliases for lsd, like `ls`
      settings = {
        date = "relative";   # Display file dates in relative format (e.g., "3 days ago")
      };
    };

    # Starship shell prompt configuration
    starship.enable = true;  # Enable Starship prompt for Fish

    # tmux configuration
    tmux = {
      enable = true;                   # Enable tmux for session management
      mouse = true;                    # Enable mouse support
      terminal = "screen-256color";    # Set terminal type for color support
      baseIndex = 1;                   # Start pane numbering at 1
      clock24 = true;                  # Display 24-hour format on the clock
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;  # Resurrect plugin for saving/restoring tmux sessions
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = tmuxPlugins.continuum;  # Continuum plugin for automatic tmux session saving
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
      ];
      extraConfig = "setenv -g EDITOR nvim\n"; # Sets default editor to Neovim within tmux
    };
  };
}

