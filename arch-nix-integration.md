## Home Manager Integration
---
A comprehensive guide for integrating Nix Home Manager with Omarchy on Arch Linux, providing a reproducible development environment while preserving Omarchy's system configurations.

Works on Omarchy v3.1.7

### Changelog
---
2025-09-04: Updated for Omarchy v2.1.x shell behavior

> - Removed references to ~/.bashrc.omarchy and ~/.zshrc.omarchy.
> - Bash now sources $HOME/.local/share/omarchy/default/bash/rc if present.
> - Noted that Omarchy does not ship a zsh rc in v2.1.x; keep zsh init in HM.
> - Minor typo and punctuation fixes.

### Table of Contents
---
1. [Prerequisites](#Prerequisites)
1. [Understanding the Stack](#Understanding)
1. [Installation](#Installation)
1. [Configuration]
1. [Shell Setup]
1. [Home Manager Command Setup]
1. [Applying Configuration]
1. [Verification]
1. [Troubleshooting]
1. [Maintenance]
1. [Optional Features]

### Prerequisites
---
- Operating System: Arch Linux with Omarchy already installed and configured
- Shell: Bash or Zsh (this guide covers both)
- Internet Connection: Required for downloading packages
- sudo privileges: For system-wide configuration changes
- Git: For version control of your configuration

### Understanding the stack
---
**What is Nix?**

Nix is a purely functional package manager that ensures reproducible builds and allows multiple versions of packages to coexist. Key benefits:

- Atomic upgrades and rollbacks
- Declarative configuration
- No dependency conflicts
- Per-user package management

**What is Home Manager?**

Home Manager uses Nix to manage your user environment declaratively. It handles:

- Dotfile management
- User-specific package installation
- Application configuration
- Environment variables

**What is Omarchy?**

Omarchy is your existing shell environment configuration system that manages:

- Hyprland window manager settings
- Ghostty terminal configuration
- System themes (Catppuccin, Gruvbox, etc.)
- Shell customizations

**Integration strategy**

We'll configure Home Manager to manage packages and configurations while respecting Omarchy's existing management of specific directories and files.

### Installation
---

### Step 1: Install Nix package manager
```console
# Check if Nix is already installed
which nix

# If not installed, run the official installer (multi-user daemon mode recommended)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Reload your shell configuration
source ~/.bashrc  # or ~/.zshrc if using zsh

# Verify installation
nix --version
```

💡 Why daemon mode? The --daemon flag installs Nix in multi-user mode, which:

- Provides better build isolation and security through dedicated build users
- Enables concurrent builds and downloads
- Prevents privilege escalation attacks
- Is required for certain Nix features like sandboxing
```

### Step 2: Enable Nix Flakes

Flakes provide reproducible, declarative, and composable package management.
```console
# Create Nix configuration directory if it doesn't exist
sudo mkdir -p /etc/nix

# Add experimental features
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf

# Restart the Nix daemon
sudo systemctl restart nix-daemon

# Verify flakes are enabled
nix flake --help

💡 Why Flakes? Flakes are marked as "experimental" but are widely used because they:

Lock all dependencies to exact versions (via flake.lock)
Ensure everyone gets identical package versions
Enable pure evaluation - builds are reproducible across machines
Provide a standard structure for Nix projects
Make it easy to share configurations via Git
```

### Step 3: Create your project structure
```console
# Create directory for your dotfiles
mkdir -p ~/.dotfiles/home-manager
cd ~/.dotfiles/home-manager

# Initialize git repository
git init
⚠️ Important: Git initialization is required for Flakes to work. Nix Flakes use Git to track which files belong to your project. Without Git, you'll get errors about "unclean" working directories.
```

### Configuration
---
#### Step 4: Create Flake configuration
```nix
Create ~/.dotfiles/home-manager/flake.nix:

{
  description = "Home Manager configuration";

  inputs = {
    # Use nixpkgs-unstable for the latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # This ensures home-manager uses the same nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Define user configurations for different devices
      userConfigs = {
        # Primary user configuration
        main = {
          username = "<username>";  # Replace with your username
          homeDirectory = "/home/<username>";  # Replace with your home path
        };

        # Add more configurations as needed
        # work = {
        #   username = "<work-username>";
        #   homeDirectory = "/home/<work-username>";
        # };
      };

      mkHomeConfig = name: config:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home.nix
            {
              home = {
                inherit (config) username homeDirectory;
                stateVersion = "24.11";
              };

              # Protect Omarchy-managed directories
              home.file.".config/omarchy".enable = false;
              home.file.".config/hypr".enable = false;
              home.file.".config/alacritty".enable = false;
              home.file.".config/btop/themes".enable = false;
            }
          ];
        };
    in {
      homeConfigurations = builtins.mapAttrs mkHomeConfig userConfigs;
    };
}
💡 Critical configuration explanations:

nixpkgs-unstable: We use the unstable channel because:

It provides the latest software versions
Updates arrive faster than stable channels
Most suitable for desktop/development use
Despite the name, it's well-tested by the community
inputs.nixpkgs.follows: This ensures Home Manager uses the exact same
nixpkgs version we specify, preventing version mismatches and conflicts.

Omarchy protection (home.file.*.enable = false): This is crucial for
coexistence:

Prevents Home Manager from managing these directories
Avoids file conflicts during home-manager switch
Lets Omarchy continue managing window manager and terminal configs
Without this, Home Manager would try to create/modify files in these
directories, causing errors
Configs structure: This design pattern allows:

Multiple user profiles (home, work, laptop, whatever you want)
Easy switching between configurations
Shared base configuration with per-device customization
Single repository for all your machines
```

### Step 5: Create Home configuration
Create ~/.dotfiles/home-manager/home.nix:

{ config, pkgs, lib, ... }:

{
  # Essential packages
  home.packages = with pkgs; [
    # Development tools
    neovim
    tmux
    git
    starship
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide

    # System utilities
    htop
    btop
    curl
    wget
    unzip
    tree
    jq

    # Modern CLI tools
    delta         # Better git diff
    tokei         # Code statistics
    bottom        # System monitor
    dust          # Disk usage analyzer
    procs         # Better ps
    lazygit       # Git TUI
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    PAGER = "less -R";
    LANG = "en_US.UTF-8";
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";  # Replace with your name
    userEmail = "your.email@example.com";  # Replace with your email

    delta = {
      enable = true;
      options = {
        theme = "Catppuccin Mocha";
        line-numbers = true;
        side-by-side = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit -m";
      cam = "commit -am";
    };
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

      # Pane navigation
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Split panes
      bind | split-window -h
      bind - split-window -v
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

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable XDG desktop integration
  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
}
💡 Key configuration explanations:

home.sessionVariables vs environment.variables:

sessionVariables are set when you log in
They're added to .profile and work across all shells
Perfect for editor, browser, and language settings
programs.* modules: These provide:

Declarative configuration instead of manual dotfiles
Automatic integration between tools (e.g., fzf + bash/zsh)
Version-locked configurations that won't break on updates
Terminal color support (tmux-256color and RGB):

Ensures true color (24-bit) support in tmux
Required for modern themes like Catppuccin
The terminal-overrides fix compatibility with various terminals
XDG desktop integration:

targets.genericLinux.enable: Adds .desktop entries for GUI apps
installed via Nix
xdg.enable: Manages XDG base directories
xdg.mime.enable: Handles file type associations
Without these, Nix-installed GUI apps won't appear in your application menu
Shell setup
Understanding PATH management
💡 The PATH challenge: When you first install Nix and Home Manager,
there's a chicken-and-egg problem:

Home Manager manages your PATH through shell configuration
But Home Manager itself needs to be in PATH to run
Until you run the first home-manager switch, it's not directly accessible
We solve this by explicitly managing PATH in our shell configuration, ensuring
all Nix tools (including Home Manager) are always available.

Step 6A: Example Bash configuration
Add to home.nix if using Bash:

  # Bash configuration
  programs.bash = {
    enable = true;

    shellAliases = {
      # Home Manager
hm = "home-manager switch --flake ~/.dotfiles/home-manager#main";

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
💡 PATH configuration details:

Explicit PATH management: The export PATH="$HOME/.nix-profile/bin:$PATH"
line:

Ensures all Nix-installed tools are available immediately
Makes home-manager command work without nix run
Preserves existing PATH entries (including Omarchy's)
Uses .nix-profile which automatically updates with your current profile
Nix daemon script: The conditional sourcing:

Handles multi-user Nix installations properly
Sets up additional environment variables Nix needs
Only runs if the file exists (avoiding errors on single-user installs)
PATH priority after this configuration:

~/.nix-profile/bin (Home Manager installed tools)
Existing PATH entries (including Omarchy's)
System paths (/usr/bin, etc.)
Initialization order:

PATH setup runs first
Tool initializations (starship, zoxide) run next
Omarchy configs are sourced last. This ensures proper precedence and allows
Omarchy overrides
Step 6B: Example Zsh configuration
Add to home.nix if using Zsh:

  # Zsh configuration
  programs.zsh = {
    enable = true;

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";  # Will be overridden by starship
      plugins = [
        "git"
        "docker"
        "kubectl"
        "terraform"
        "aws"
        "npm"
        "pip"
        "python"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "extract"
      ];
    };

    shellAliases = {
      # Home Manager
hm = "home-manager switch --flake ~/.dotfiles/home-manager#main";

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
      eval "$(starship init zsh)"

      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # Omarchy does not ship a zsh rc in v2.1.x; keep PATH and init in HM/zshrc.
      # If you need Omarchy CLI tools on PATH:
      export PATH="$HOME/.local/share/omarchy/bin:$PATH"

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

      # Extract function for archives
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.tar.xz) tar xJf "$1" ;;
            *.zip) unzip "$1" ;;
            *.rar) unrar x "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
    '';
  };
💡 Oh My Zsh integration notes:

Theme override: We set a theme but Starship overrides it because:

Oh My Zsh requires a theme to be set
Starship provides a more powerful, cross-shell prompt
This prevents Oh My Zsh from complaining about missing themes
Plugin selection: These plugins are chosen because:

They don't conflict with our Nix-installed tools
They provide completions and conveniences
They're maintained by the Oh My Zsh community
Heavy plugins that slow down shell startup are avoided
Alternative: Omarchy PATH integration
💡 Alternative Approach: If you prefer to keep PATH management outside of
Home Manager, you can add this directly to your shell rc:

# Bash (Omarchy v2.1.x ships a ~/.bashrc): add to ~/.bashrc
export PATH="$HOME/.nix-profile/bin:$PATH"

# Zsh: add to ~/.zshrc (Omarchy does not ship a zsh rc)
export PATH="$HOME/.nix-profile/bin:$PATH"
This approach:

Keeps PATH setup local to your shell rc
Makes Nix tools available without modifying Home Manager config
Might be preferred if you centralize PATH logic outside HM
Home Manager command setup
The problem
When using Home Manager with flakes, the home-manager command is not installed as a package. Instead, it's accessed through nix run home-manager. This creates a chicken-and-egg problem on new machines where you need Home Manager to set up your environment, but Home Manager itself isn't directly accessible.

Solution: Wrapper script
We solve this by creating a wrapper script that makes home-manager available
as a direct command.

Create the wrapper
Location: ~/.local/bin/home-manager

# Create the local bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Create the wrapper script
cat > ~/.local/bin/home-manager << 'EOF'
#!/usr/bin/env bash
# Home Manager wrapper for flake-based installations
# This makes 'home-manager' available as a direct command

exec nix run home-manager -- "$@"
EOF

# Make it executable
chmod +x ~/.local/bin/home-manager

# Ensure ~/.local/bin is in PATH (add to shell config if needed)
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
💡 Why this works:

The wrapper makes home-manager available immediately, even before the
first switch
It uses nix run internally, which is the correct way to access flake-based
Home Manager
Once Home Manager sets up your shell configuration, all PATH management is
handled automatically
The wrapper remains useful for consistency across all machines
Available commands
After setting up the wrapper, you can use Home Manager commands directly:

home-manager switch --flake ~/.dotfiles/home-manager#main - Apply
configuration
home-manager generations - List all generations
home-manager rollback - Rollback to previous generation
home-manager --help - See all available commands
Bootstrap process on a new machine
Install Nix
Clone dotfiles
Create the wrapper script (steps above)
Run initial switch:
Run home-manager switch --flake ~/.dotfiles/home-manager#main
After first switch, all commands and aliases are available
Applying configuration
Step 7: Initialize and apply
# Save and stage your configuration files
cd ~/.dotfiles/home-manager
git add flake.nix home.nix
git commit -m "Initial Home Manager configuration"

# Apply the configuration (using our wrapper)
home-manager switch --flake ~/.dotfiles/home-manager#main

# If you named your configuration differently, use:
# home-manager switch --flake ~/.dotfiles/home-manager#<config-name>
⚠️ Why Git commit is required:

Flakes only see files tracked by Git
Uncommitted changes are invisible to Nix
This ensures reproducibility - anyone cloning your repo gets the same result
The error "Git tree is dirty" means you have uncommitted changes
Step 8: Set default shell (if using Zsh)
# Add Nix-installed zsh to valid shells
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells

# Change default shell
chsh -s "$HOME/.nix-profile/bin/zsh"

# Log out and back in for changes to take effect
💡 Shell path explanation:

We use the Nix-installed shell, not the system one
This ensures your shell has access to Nix paths
The path ~/.nix-profile/bin/ is a symlink to your current profile
This survives Home Manager updates and switches
Verification
Basic checks
# Check environment variables
echo $EDITOR     # Should output: nvim
echo $LANG       # Should output: en_US.UTF-8

# Verify installed tools
which starship   # Should show Nix profile path
which eza        # Should show Nix profile path
which bat        # Should show Nix profile path

# Test aliases
ll               # Should run eza with icons
cat ~/.bashrc    # Should use bat with syntax highlighting

# Check starship prompt
# You should see a styled prompt in your terminal

# Verify Home Manager is directly accessible
which home-manager  # Should show: /home/<username>/.local/bin/home-manager
hm  # Should work without 'nix run'
Verify Omarchy protection
# These directories should still be managed by Omarchy
ls -la ~/.config/omarchy/
ls -la ~/.config/hypr/
ls -la ~/.config/alacritty/

# Home Manager should not have created any files in these directories
Troubleshooting
Common issues
1. "home-manager: command not found"

If you haven't set up the wrapper script yet:

# Create the wrapper (see Home Manager Command Setup section)
mkdir -p ~/.local/bin
cat > ~/.local/bin/home-manager << 'EOF'
#!/usr/bin/env bash
exec nix run home-manager -- "$@"
EOF
chmod +x ~/.local/bin/home-manager

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"

# Then retry
home-manager switch --flake ~/.dotfiles/home-manager#main
💡 Wrapper troubleshooting:

Ensure the wrapper is executable: ls -la ~/.local/bin/home-manager
Check if ~/.local/bin is in PATH: echo $PATH | grep .local/bin
Try the wrapper directly: ~/.local/bin/home-manager --help
2. File conflicts during switch

# Back up conflicting files
mv ~/.bashrc ~/.bashrc.backup
mv ~/.config/starship.toml ~/.config/starship.toml.backup

# Retry the switch
home-manager switch --flake ~/.dotfiles/home-manager#main
💡 Conflict resolution: Home Manager wants to manage these files completely. By moving them, you're letting Home Manager take control while keeping backups of your original configs.

3. "Git tree is dirty" warning

cd ~/.dotfiles/home-manager
git add -A
git commit -m "Update configuration"
4. Nix commands not found after installation

# Manually source Nix
. ~/.nix-profile/etc/profile.d/nix.sh

# Add to your shell RC file
echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc
5. Starship prompt not showing

Open a new terminal window
Check if starship init is in your shell configuration
Run starship init bash or starship init zsh manually to test
Getting help
# View Home Manager options
man home-configuration.nix

# Check Nix logs
journalctl -u nix-daemon

# Debug with trace
home-manager switch --flake ~/.dotfiles/home-manager#main --show-trace

# List generations (for rollback)
home-manager generations
Maintenance
Updating packages
# Update flake inputs
cd ~/.dotfiles/home-manager
nix flake update

# Apply updates
home-manager switch --flake ~/.dotfiles/home-manager#main
💡 Update process:

nix flake update updates the flake.lock file
This pulls in the latest versions of all inputs
The lock file ensures everyone gets the same versions
Commit the updated lock file to share updates
Convenience aliases
Our Home Manager configuration includes these aliases:

hm - Quick switch (equivalent to
home-manager switch --flake ~/.dotfiles/home-manager#main)
nix-upgrade - Pull dotfiles and apply Home Manager changes (if configured)
hm-update - Update flake inputs (package versions)
Rollback
# List generations
home-manager generations

# Rollback to previous
home-manager rollback

# Switch to specific generation
home-manager switch-generation <number>
💡 Generation system:

Every home-manager switch creates a new generation
Generations are complete snapshots of your environment
Old generations are kept until manually cleaned
This provides a safety net for configuration changes
Rollback is instant - just changes symlinks
Adding new packages
Edit home.nix and add packages to the home.packages list
Run home-manager switch --flake ~/.dotfiles/home-manager#main
Commit your changes to git
Managing multiple devices
To add a new device configuration:

Edit flake.nix and add to userConfigs:

laptop = {
  username = "<laptop-username>";
  homeDirectory = "/home/<laptop-username>";
};
Switch using:

home-manager switch --flake ~/.dotfiles/home-manager#laptop
💡 Multi-device strategy:

One repository serves all your machines
Share common configuration, customize per-device
Easy to keep configurations in sync
Can extend with device-specific settings later
Optional features
Jujutsu Version Control
If you prefer Jujutsu over Git, add to home.nix:

home.packages = with pkgs; [
  # ... other packages ...
  jujutsu
];

# In your shell configuration, add:
shellAliases = {
  # ... other aliases ...
  jj = "jujutsu";
  jjs = "jj status";
  jjl = "jj log";
};
Configure after installation:

jj config set --user ui.editor nvim
jj config set --user user.name "Your Name"
jj config set --user user.email "your.email@example.com"
Automated updates
Create an upgrade script at ~/.local/bin/upgrade-nix:

#!/usr/bin/env bash
set -e

echo "Updating Nix flakes..."
cd ~/.dotfiles/home-manager
nix flake update

echo "Applying Home Manager configuration..."
home-manager switch --flake .#main

echo "Update complete!"
Make it executable:

chmod +x ~/.local/bin/upgrade-nix
Add alias to your shell configuration:

shellAliases = {
  # ... other aliases ...
  nix-upgrade = "~/.local/bin/upgrade-nix";
};
Systemd timer for automatic updates
Create ~/.config/systemd/user/nix-upgrade.service:

[Unit]
Description=Nix Home Manager Upgrade
After=network-online.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/upgrade-nix
StandardOutput=journal
StandardError=journal
Create ~/.config/systemd/user/nix-upgrade.timer:

[Unit]
Description=Weekly Nix Upgrade
Persistent=true

[Timer]
OnCalendar=weekly
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
Enable the timer:

systemctl --user daemon-reload
systemctl --user enable --now nix-upgrade.timer
💡 Automation benefits:

Keeps your tools up-to-date automatically
Persistent=true runs missed timers after reboot
Random delay prevents everyone hitting nixpkgs at once
Logs to systemd journal for debugging
Can disable anytime with systemctl --user disable
Best practices
Version Control: Always commit working configurations before making
changes
Test First: Use home-manager build before switch to catch errors
Document Changes: Use meaningful commit messages
Regular Updates: Update packages weekly or monthly
Backup: Keep copies of working configurations
Modular Configuration: As your config grows, split it into multiple files
Summary
You now have a fully integrated Nix Home Manager setup that:

Manages your development tools declaratively
Respects Omarchy's system configurations
Provides reproducible environments across devices
Supports both Bash and Zsh shells
Enables easy rollbacks and updates
Makes all Nix tools (including Home Manager) directly accessible via wrapper
script
For questions or issues, consult the
Nix manual and
Home Manager manual.
