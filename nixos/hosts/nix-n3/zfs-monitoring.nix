{ config, ... }:

{
  sops.secrets.zed-ntfy-env = {
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [ "zfs-zed.service" ];
  };

  services.zfs.zed = {
    enableMail = false;

    settings = {
      # Notify about permanent data errors and rate-limit repeated events.
      ZED_NOTIFY_DATA = true;
      ZED_NOTIFY_INTERVAL_SECS = 3600;

      # Beszel records successful scrubs; ZED only reports unhealthy results.
      ZED_NOTIFY_VERBOSE = false;
    };
  };

  # ZED_NTFY_URL and ZED_NTFY_TOPIC are loaded at runtime so they do not
  # become part of the Nix store.
  systemd.services.zfs-zed.serviceConfig.EnvironmentFile = [
    config.sops.secrets.zed-ntfy-env.path
  ];
}
