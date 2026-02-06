{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.git
    pkgs.neovim
    pkgs.python312
    pkgs.nodejs
  ];
  cachix.enable = false;
  enterShell = ''
    exec bash
  '';
}
