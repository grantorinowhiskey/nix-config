{ pkgs, ... }:

{
  sops.secrets = {
    "copyparty-jt-password" = {
      owner = "copyparty";
    };
  };

  networking.firewall.allowedTCPPorts = [
    3210
    3211
  ];

  services.copyparty = {
    enable = true;
    user = "copyparty";
    group = "copyparty";

    settings = {
      i = "0.0.0.0";
      p = [
        3210
        3211
      ];
    };

    accounts = {
      jt = {
        passwordFile = "/run/secrets/copyparty-jt-password";
      };
    };

    volumes = {
      "/" = {
        path = "/mnt/copyparty";
        r = "*";
        rw = [ "jt" ];
      };
    };
    openFilesLimit = 8192;
  };
}
