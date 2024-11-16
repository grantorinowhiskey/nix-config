# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, config, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Europe/Stockholm";
    };
    volumes = [
      "/home/jt/appdata/jellyfin/library:/config:rw"
      "/tank/media/movies:/data/movies:rw"
      "/tank/media/shows:/data/tvshows:rw"
    ];
    ports = [
      "8096:8096/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=jellyfin"
      "--network=containers_default"
    ];
  };
  systemd.services."docker-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-containers_default.service"
    ];
    requires = [
      "docker-network-containers_default.service"
    ];
    partOf = [
      "docker-compose-containers-root.target"
    ];
    wantedBy = [
      "docker-compose-containers-root.target"
    ];
  };
  virtualisation.oci-containers.containers."nginxproxymanager" = {
    image = "jc21/nginx-proxy-manager:latest";
    volumes = [
      "/home/jt/appdata/nginx/data:/data:rw"
      "/home/jt/appdata/nginx/letsencrypt:/etc/letsencrypt:rw"
    ];
    ports = [
      "80:80/tcp"
      "81:81/tcp"
      "443:443/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=nginxproxymanager"
      "--network=containers_default"
    ];
  };
  systemd.services."docker-nginxproxymanager" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-containers_default.service"
    ];
    requires = [
      "docker-network-containers_default.service"
    ];
    partOf = [
      "docker-compose-containers-root.target"
    ];
    wantedBy = [
      "docker-compose-containers-root.target"
    ];
  };
  virtualisation.oci-containers.containers."radarr" = {
    image = "lscr.io/linuxserver/radarr:latest";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Europe/Stockholm";
    };
    volumes = [
      "/home/jt/appdata/radarr/config:/config:rw"
    ];
    ports = [
      "7878:7878/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr"
      "--network=containers_default"
    ];
  };
  systemd.services."docker-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-containers_default.service"
    ];
    requires = [
      "docker-network-containers_default.service"
    ];
    partOf = [
      "docker-compose-containers-root.target"
    ];
    wantedBy = [
      "docker-compose-containers-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sabnzbd" = {
    image = "lscr.io/linuxserver/sabnzbd:latest";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Europe/Stockholm";
    };
    volumes = [
      "/home/jt/appdata/sabnzbd/config:/config:rw"
    ];
    ports = [
      "8080:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sabnzbd"
      "--network=containers_default"
    ];
  };
  systemd.services."docker-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-containers_default.service"
    ];
    requires = [
      "docker-network-containers_default.service"
    ];
    partOf = [
      "docker-compose-containers-root.target"
    ];
    wantedBy = [
      "docker-compose-containers-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sonarr" = {
    image = "lscr.io/linuxserver/sonarr:latest";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Europe/Stockholm";
    };
    volumes = [
      "/home/jt/appdata/sonarr/data:/config:rw"
    ];
    ports = [
      "8989:8989/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr"
      "--network=containers_default"
    ];
  };
  systemd.services."docker-sonarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-containers_default.service"
    ];
    requires = [
      "docker-network-containers_default.service"
    ];
    partOf = [
      "docker-compose-containers-root.target"
    ];
    wantedBy = [
      "docker-compose-containers-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-containers_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f containers_default";
    };
    script = ''
      docker network inspect containers_default || docker network create containers_default
    '';
    partOf = [ "docker-compose-containers-root.target" ];
    wantedBy = [ "docker-compose-containers-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-containers-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}