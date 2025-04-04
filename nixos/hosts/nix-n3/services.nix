{ config, pkgs, nixpkgs-unstable, nixpkgs-e08a8231, lib, ... }:

{
  # multimedia user group, necessary for services access to directories
  users.groups.multimedia = {};

  # Auto renewed SSL certificates
  security.acme = {
    acceptTerms = true;
    defaults.email = "z6lbxfnhi@mozmail.com";
    certs."ynso.duckdns.org" = {
      domain = "*.ynso.duckdns.org";
      dnsProvider = "duckdns";
      dnsPropagationCheck = true;
      credentialFiles = { "DUCKDNS_TOKEN_FILE" = config.sops.secrets."duckdns-token".path;
      };
    };
  };

  # Allow nginx to use certs from acme
  users.users.nginx.extraGroups = [ "acme" ];

  # nginx reverse proxy
  services.nginx = {
    enable = true;
    virtualHosts = {

      # jellyfin
      "jellyfin.ynso.duckdns.org" = {
        useACMEHost = "ynso.duckdns.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };

      # sabnzbd
      "sabnzbd.ynso.duckdns.org" = {
        useACMEHost = "ynso.duckdns.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
        };
      };

      # radarr
      "radarr.ynso.duckdns.org" = {
        useACMEHost = "ynso.duckdns.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7878";
          extraConfig =''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
          '';
        };
      };

      # sonarr
      "sonarr.ynso.duckdns.org" = {
        useACMEHost = "ynso.duckdns.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8989";
        };
      };

    };
  };

  services.jellyfin = {
    enable = true;
    # port 8096
    group = "multimedia";
  };

  services.sabnzbd = {
    enable = true;
    # port 8080
    group = "multimedia";
  };

  services.radarr = {
    enable = true;
    # port 7878
    group = "multimedia";
  };

  services.sonarr = {
    enable = true;
    # port 8989
    package = nixpkgs-e08a8231.sonarr;
  };

}