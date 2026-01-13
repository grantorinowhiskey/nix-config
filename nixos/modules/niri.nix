{ pkgs, ... }:

{
  programs.niri.enable = true;

  # Other necessities
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = {};

  # programs.waybar.enable = true; # top bar - disabled because of double waybars


  environment.systemPackages = with pkgs; [
    alacritty
    adw-bluetooth
    brightnessctl
    fuzzel
    swaylock
    mako
    swaybg
    swayidle
    waybar
    waypaper
    xwayland-satellite
    ];


  
}
