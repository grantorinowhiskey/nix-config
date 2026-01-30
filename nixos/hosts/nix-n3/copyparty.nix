{ pkgs, ... }:

{
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
        passwordFile = "/run/keys/copyparty/jt_password";
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
