{ config, pkgs, lib, ... }:

{
  # Essential packages
  home.packages = with pkgs; [
    # Development tools
    bat
    devenv
    eza
    fd
    fzf
    git
    neovim
    ripgrep
    starship
    tmux
    zoxide

    # System utilities
    btop
    curl
    jq
    tree
    unzip
    wget

    # Modern CLI tools
    bottom        # System monitor
    delta         # Better git diff
    dust          # Disk usage analyzer
    lazygit       # Git TUI
    procs         # Better ps
    tokei         # Code statistics
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "chromium";
    PAGER = "less -R";
    LANG = "en_US.UTF-8";
  };

  # Git configuration
  programs.git.settings = {
    enable = true;
    user = {
      name = "ealvar3z";  # Replace with your name
      email = "55966724+ealvar3z@users.noreply.github.com";  # Replace with your email
    };
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit -m";
      cam = "commit -am";
    };
  };
  
  programs.delta.options = {
      enable = true;
      theme = "Catppuccin Mocha";
      line-numbers = true;
      side-by-side = true;
  };


  # Starship prompt configuration
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$line_break$character";

      character = {
        success_symbol = "[❯](bold mauve)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold blue";
        truncate_to_repo = false;
      };

      git_branch = {
        style = "bold purple";
      };
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"
    '';
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
  };

  # Bash configuration
  programs.bash = {
    enable = true;

    shellAliases = {
      # Home Manager
      hm = "home-manager switch --flake $HOME/repos/nix-workspace#main";

      c = "clear";
      x = "exit";

      # ls replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";

      # Modern replacements
      cat = "bat";
      grep = "rg";
      find = "fd";

      # Git shortcuts
      g = "git";
      gst = "git status";
      gco = "git checkout";
      gcm = "git commit -m";
      gcam = "git commit -am";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    initExtra = ''
      # CRITICAL: Ensure Nix binaries are in PATH
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # Source Nix daemon script if it exists (for multi-user installs)
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # Initialize starship prompt
      eval "$(starship init bash)"

      # Initialize zoxide
      eval "$(zoxide init bash)"

      # Include Omarchy bash layer (v2.1.x ships a ~/.bashrc that sources this)
      if [ -f "$HOME/.local/share/omarchy/default/bash/rc" ]; then
        . "$HOME/.local/share/omarchy/default/bash/rc"
      fi

      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Better cd with zoxide fallback
      cd() {
        if [ -d "$1" ] || [ -z "$1" ]; then
          builtin cd "$@"
        else
          z "$@"
        fi
      }
    '';
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable XDG desktop integration
  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
}
