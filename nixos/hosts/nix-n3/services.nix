{
  services.nginx = {
    enable = true;
    virtualHosts."ynso.duckdns.org" = {
      useACMEHost = "ynso.duckdns.org";
      forceSSL = true;
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "z6lbxfnhi@mozmail.com";
    certs."ynso.duckdns.org" = {
      domain = "ynso.duckdns.org";
      extraDomainNames = [ "jellyfin.ynso.duckdns.org" ];
      dnsProvider = "duckdns";
      dnsPropagationCheck = true;
      # here we need a sops-nix solution to bring in DUCKDNS_TOKEN
      credentialFiles = "/run/secrets/duckdns-token";
    };

    users.users.nginx.extraGroups = [ "acme" ];
  };






}

 