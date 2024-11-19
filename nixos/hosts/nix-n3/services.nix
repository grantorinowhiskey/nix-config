{ config, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "z6lbxfnhi@mozmail.com";
    certs."ynso.duckdns.org" = {
      domain = "ynso.duckdns.org";
      extraDomainNames = [ "jellyfin.ynso.duckdns.org" ];
      dnsProvider = "duckdns";
      dnsPropagationCheck = true;
      # here we need a sops-nix solution to bring in DUCKDNS_TOKEN
      credentialFiles = { "DUCKDNS_TOKEN_FILE" = config.sops.secrets."duckdns-token".path; 
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  
  services.nginx = {
    enable = true;
    virtualHosts."jellyfin.ynso.duckdns.org" = {
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

}