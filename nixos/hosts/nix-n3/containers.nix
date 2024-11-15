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
  virtualisation.oci-containers.containers."sabnzbd" = {
    image = "lscr.io/linuxserver/sabnzbd:latest";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "Europe/Stockholm";
    };
    volumes = [
      "/home/jt/appdata/sabnzbd/downloads:/downloads:rw"
      "/home/jt/appdata/sabnzbd/downloads:/incomplete-downloads:rw"
      "/home/jt/appdata/sabnzbd/config:/config:rw"
    ];
    ports = [
      "8080:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sabnzbd"
      "--network=sabnzbd_default"
    ];
  };
  systemd.services."podman-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-sabnzbd_default.service"
    ];
    requires = [
      "podman-network-sabnzbd_default.service"
    ];
    partOf = [
      "podman-compose-sabnzbd-root.target"
    ];
    wantedBy = [
      "podman-compose-sabnzbd-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-sabnzbd_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f sabnzbd_default";
    };
    script = ''
      podman network inspect sabnzbd_default || podman network create sabnzbd_default
    '';
    partOf = [ "podman-compose-sabnzbd-root.target" ];
    wantedBy = [ "podman-compose-sabnzbd-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-sabnzbd-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
