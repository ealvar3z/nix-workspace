{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.htop
    pkgs.tmux
    pkgs.nmap
  ];
  enterShell = ''
    exec bash
  '';
}
