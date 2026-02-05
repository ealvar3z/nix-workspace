{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.hashcat
    pkgs.john
    pkgs.openssl
    pkgs.gmp
  ];
  enterShell = ''
    exec bash
  '';
}
