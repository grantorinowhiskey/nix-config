{ pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "";
  };

  # Install GNOME Extensions and dark theme for GTK3
  environment.systemPackages = with pkgs; [
   adw-gtk3
   gnomeExtensions.alphabetical-app-grid
   gnomeExtensions.blur-my-shell
   gnomeExtensions.caffeine
   gnomeExtensions.middle-click-to-close-in-overview
   gnomeExtensions.mullvad-indicator
   gnomeExtensions.battery-health-charging
   gnomeExtensions.tailscale-qs
   gnome-tweaks
  ];

  # Exclusion of certain gnome applications
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-console
    gnome-music
    epiphany # web browser
    geary # email reader
    gnome-characters
    totem # video player
    gnome-system-monitor
  ]);
}
