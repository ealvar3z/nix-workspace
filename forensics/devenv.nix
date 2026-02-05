{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.binwalk
    pkgs.tshark
    pkgs.exiftool
    pkgs.bulk_extractor
  ];
  enterShell = ''
    exec bash
  '';
}
