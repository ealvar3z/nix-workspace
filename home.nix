{ pkgs, nixgl, ... }:

{
  nixpkgs.config.allowUnfree = true;
  home.username = "eax";
  home.homeDirectory = "/home/eax";
  home.stateVersion = "23.11";

  # Home Manager itself
  programs.home-manager.enable = true;

  # bash shell with everforest colored prompt
  programs.bash = {
    enable = true;
    interactiveShellInit = ''
      set -g theme_everforest_background "hard"
      set -g themeeverforest_palette "medium"
      # Custom minimal everforest prompt
      function bash_prompt
        set_color -o "#a7c080"
        echo -n (whoami)"@"(hostname)" "
        set_color -o "#7fbbb3"
        echo -n (prompt_pwd)""
        set_color -o "#dbbc7f"
        echo -n "> "
        set_color normal
      end
      source /usr/share/cachyos-bash-config/cachyos-config.bash
 zoxide init bash | source
      direnv bash | source
      # potentially disabling fastfetch
      function bash_greeting
      end
      pyenv init - | source
      pyenv virtualenv-init - | source
      if test -e ~/.nix-profile/etc/profile.d/nix.bash
        source ~/.nix-profile/etc/profile.d/nix.bash
      end
    '';
    shellInit = ''
      if test -e ~/.nix-profile/etc/profile.d/nix.bash
        source ~/.nix-profile/etc/profile.d/nix.bash
      end
    '';
    shellAliases = {
      vim = "nvim";
      c = "z";
      gs = "git status";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd c" ];
  };

  # Editor: point to .config/nvim for neovim config
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # Everforest theme for terminal (kitty), neovim, rofi

  # VSCode
 programs.vscode = {
    enable = true;
  };

  # Tool launcher: rofi with Alt+D binding, everforest theme via user config sync
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun run";
      show-icons = true;
    };
    theme = null; # for user-level theming via ~/.config/rofi
  };

  # Clipboard manager
  services.clipman.enable = true;

  # Tools
  home.packages = with pkgs; [
    nmap
    rustscan
    gobuster
    wget
    git
    curl
    tmux
    zip
    unzip
    ruby
    wireshark
    ghidra
    rofi
    xh
    wireguard-tools
    rustc
    cargo
    vscode
    # goose
    xclip # for clipboard fallback
    devenv
  ];

}
