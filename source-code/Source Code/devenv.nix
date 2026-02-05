{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.ctags
    pkgs.semgrep
    pkgs.gitleaks
  ];
  enterShell = ''
    exec bash
  '';
}
