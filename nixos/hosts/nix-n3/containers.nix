# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

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
  systemd.services."podman-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-containers_default.service"
    ];
    requires = [
      "podman-network-containers_default.service"
    ];
    partOf = [
      "podman-compose-containers-root.target"
    ];
    wantedBy = [
      "podman-compose-containers-root.target"
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
  systemd.services."podman-nginxproxymanager" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-containers_default.service"
    ];
    requires = [
      "podman-network-containers_default.service"
    ];
    partOf = [
      "podman-compose-containers-root.target"
    ];
    wantedBy = [
      "podman-compose-containers-root.target"
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
  systemd.services."podman-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-containers_default.service"
    ];
    requires = [
      "podman-network-containers_default.service"
    ];
    partOf = [
      "podman-compose-containers-root.target"
    ];
    wantedBy = [
      "podman-compose-containers-root.target"
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
  systemd.services."podman-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-containers_default.service"
    ];
    requires = [
      "podman-network-containers_default.service"
    ];
    partOf = [
      "podman-compose-containers-root.target"
    ];
    wantedBy = [
      "podman-compose-containers-root.target"
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
  systemd.services."podman-sonarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-containers_default.service"
    ];
    requires = [
      "podman-network-containers_default.service"
    ];
    partOf = [
      "podman-compose-containers-root.target"
    ];
    wantedBy = [
      "podman-compose-containers-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-containers_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f containers_default";
    };
    script = ''
      podman network inspect containers_default || podman network create containers_default
    '';
    partOf = [ "podman-compose-containers-root.target" ];
    wantedBy = [ "podman-compose-containers-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-containers-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
