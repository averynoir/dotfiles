# gnome.nix

{ config, pkgs, lib, ... }:

{

####################################################################################################

  ## GNOME Desktop Environment. ##
  
  services.xserver.enable = true;  # Enable the X11 windowing system.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  ## GNOME Desktop. ##

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Excluding some GNOME applications.
  environment.gnome.excludePackages = (with pkgs; [
    # packages
  ]) ++ (with pkgs; [
    # packages
  ]);
  
  # GNOME Extensions.
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.arcmenu
    gnomeExtensions.wiggle
    gnome-tweaks
    gnomeExtensions.just-perfection
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.tweaks-in-system-menu
  ];
  
  # Ensure gnome-settings-daemon udev rules are enabled.
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  
  # Qt applications GNOME desktop integration.
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  
  # GSConnect (KDE Connect for GNOME)
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

####################################################################################################

}
