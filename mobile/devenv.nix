{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.frida-tools
    pkgs.android-tools   # provides adb
    pkgs.apktool
    # smali/baksmali not in nixpkgs—see official releases if needed
  ];
  enterShell = ''
    exec bash
  '';
}
