{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.gdb
    pkgs.qemu
    pkgs.strace
    pkgs.pwntools
  ];
  enterShell = ''
    exec bash
  '';
}
