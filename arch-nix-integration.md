## Home Manager Integration
---
[A comprehensive guide for integrating Nix Home Manager with Omarchy on Arch Linux, providing a reproducible development environment while preserving Omarchy's system configurations. See current link.](https://github.com/basecamp/omarchy/discussions/987)

### Bootstrap process on a new machine
1. Install Nix
1. Clone dotfiles
1. Create the wrapper script (steps above)
1. Run initial switch:
1. Run `home-manager switch --flake ~/.nix-workspace/home#main`
1. After first switch, all commands and aliases are available

