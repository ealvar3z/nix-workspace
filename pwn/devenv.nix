{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.gdb
    pkgs.pwntools
    pkgs.radare2
    pkgs.strace
    pkgs.ghidra
  ];
  enterShell = ''
    exec bash
  '';
}
