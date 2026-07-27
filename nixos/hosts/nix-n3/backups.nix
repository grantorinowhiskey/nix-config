{
  config,
  pkgs,
  ...
}:

let
  sourceDirectory = "/tank/backups/Anteckningar";
  mountDirectory = "/run/anteckningar-rsync-net/crypt";
  gocryptfsConfig = "/var/lib/anteckningar-rsync-net/gocryptfs.conf";
  remote = "zh5530@zh5530.rsync.net:backups/Anteckningar-crypt/";
in
{
  sops.secrets.anteckningar-gocryptfs-pass = {
    owner = "backups";
    group = "users";
    mode = "0400";
  };

  systemd.services.anteckningar-rsync-net = {
    description = "Krypterad backup av Anteckningar till rsync.net";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = with pkgs; [
      coreutils
      fuse3
      gocryptfs
      openssh
      rsync
      util-linux
    ];

    script = ''
      set -eu

      if [ ! -f ${gocryptfsConfig} ]; then
        echo "Gocryptfs är inte initierat. Se instruktionerna i backups.nix." >&2
        exit 1
      fi

      cleanup() {
        if mountpoint -q ${mountDirectory}; then
          fusermount3 -u ${mountDirectory}
        fi
      }
      trap cleanup EXIT

      gocryptfs \
        -reverse \
        -passfile ${config.sops.secrets.anteckningar-gocryptfs-pass.path} \
        -config ${gocryptfsConfig} \
        ${sourceDirectory} \
        ${mountDirectory}

      rsync \
        --archive \
        --human-readable \
        --partial \
        -e "ssh -o BatchMode=yes -o ConnectTimeout=30" \
        ${mountDirectory}/ \
        ${remote}

      # Konfigurationen innehåller huvudnyckeln krypterad med lösenordet
      # och måste finnas med för att backupen ska kunna återställas.
      rsync \
        --archive \
        -e "ssh -o BatchMode=yes -o ConnectTimeout=30" \
        ${gocryptfsConfig} \
        ${remote}gocryptfs.conf
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "backups";
      Group = "users";
      UMask = "0077";

      RuntimeDirectory = "anteckningar-rsync-net/crypt";
      RuntimeDirectoryMode = "0700";
      StateDirectory = "anteckningar-rsync-net";
      StateDirectoryMode = "0700";

      DeviceAllow = "/dev/fuse rw";
    };
  };

  systemd.timers.anteckningar-rsync-net = {
    description = "Kör krypterad backup av Anteckningar varje natt";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "*-*-* 03:30:00";
      Persistent = true;
      Unit = "anteckningar-rsync-net.service";
    };
  };

  # Snapshot-hantering med Sanoid
  services.sanoid = {
    enable = true;
    templates.backup = {
      hourly = 12;
      daily = 30;
      monthly = 6;
      yearly = 0;
      autoprune = true;
      autosnap = true;
    };
    datasets."tank/backups" = {
      useTemplate = [ "backup" ];
    };
  };
}
