{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}