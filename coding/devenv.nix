{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.git
    pkgs.neovim
    pkgs.python312
    pkgs.nodejs
  ];
  enterShell = ''
    exec bash
  '';
}
