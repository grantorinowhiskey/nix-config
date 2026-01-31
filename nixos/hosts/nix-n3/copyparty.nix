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
      rproxy = 1;
      xff-src = "192.168.1.137";
      xff-hdr = "x-forwarded-for";
    };

    accounts = {
      jt = {
        passwordFile = "/run/secrets/copyparty-jt-password";
      };
    };

    volumes = {
      "/" = {
        path = "/mnt/copyparty";
        access = {
          r = "*";
          A = [ "jt" ];
        };

      };
    };
    openFilesLimit = 8192;
  };
}
