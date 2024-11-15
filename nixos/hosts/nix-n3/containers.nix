{ pkgs, config, ... }:
{
  # Enable common container config files in /etc/containers
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers = {
    sabnzbd = {
      image = "lscr.io/linuxserver/sabnzbd:latest";
      autoStart = true;
      ports = [ "8080:8080" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Stockholm";
      };
      volumes = [
        "/home/jt/appdata/sabnzbd/config:/config"
        "/home/jt/appdata/sabnzbd/downloads:/downloads"
        "/home/jt/appdata/sabnzbd/incomplete-downloads:/incomplete-downloads"
      ];
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoStart = true;
      ports = [ "7878:7878" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Stockholm";
      };
      volumes = [
        "/home/jt/appdata/radarr/config:/config"
      ];
    };
  };
}
