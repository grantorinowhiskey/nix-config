{ config, pkgs, lib, ... }:

let
  nixpkgs.overlays = [
    # GNOME 46: triple-buffering-v4-46
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs ( old: {
          src = pkgs.fetchgit {
            url = "https://gitlab.gnome.org/vanvugt/mutter.git";
			rev = "663f19bc02c1b4e3d1a67b4ad72d644f9b9d6970";
            sha256 = "sha256-I1s4yz5JEWJY65g+dgprchwZuPGP9djgYXrMMxDQGrs=";         
          };
        } );
      });
    })
  ];
in
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jt";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
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
  ];

  # Exclusion of certain gnome applications
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-console    
  ]) ++ (with pkgs.gnome; [
    gnome-music
    epiphany # web browser
    geary # email reader
    gnome-characters
    totem # video player
    gnome-system-monitor
  ]);
}
