{ config, pkgs, ... }:
{
  imports = [ ];

  users.users.eax = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/eax";
    shell = pkgs.bash;
  };

  # GNOME desktop with Forge/Autotiler Extension
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Enable forge/autotiler (GNOME extension)
  environment.gnome.excludePackages = with pkgs.gnomeExtensions; [  ]; # Avoid duplicate preinstalls
  environment.systemPackages = with pkgs; [
    gnomeExtensions.forge
  ];

  # Home Manager system module
  programs.home-manager.enable = true;

  networking.networkmanager.enable = true;
}
