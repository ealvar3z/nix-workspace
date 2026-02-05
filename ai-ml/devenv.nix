{ pkgs, ... }:

{
  packages = [
    pkgs.bash
    pkgs.python312
    pkgs.python312Packages.scikit-learn
    pkgs.python312Packages.numpy
    pkgs.python312Packages.pandas
    pkgs.python312Packages.torch
  ];
  enterShell = ''
    exec bash
  '';
}
