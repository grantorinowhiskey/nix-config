{ pkgs, ... }:

{
  programs.niri.enable = true;

  # Other necessities
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = {};

  programs.waybar.enable = true; # top bar


  environment.systemPackages = with pkgs; [ fuzzel swaylock mako swayidle ];


  
}
