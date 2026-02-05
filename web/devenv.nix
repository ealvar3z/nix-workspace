{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.nmap
    pkgs.gobuster
    pkgs.zap
    pkgs.feroxbuster
  ];
  enterShell = ''
    exec bash
  '';
}
