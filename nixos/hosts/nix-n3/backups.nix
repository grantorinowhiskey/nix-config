{ config, pkgs, ...}:

{
  # systemd-service for backup
  systemd.services.dokument-backup = {
    description = "Backup Syncthing Documents";
    serviceConfig = {
      Type = "oneshot";
      User = "jt";
      ExecStart = "${pkgs.rsync}/bin/rsync -avz --delete /home/jt/appdata/syncthing/data/Dokument/ /tank/backups/Dokument/";
    };
  };

  # Timer to run backup script periodically
  systemd.timers.dokument-backup = {
    description = "Timer for Dokument backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00:00";
      Persistent = true;
    };
  };

  #### 🛡️ Krypterat lösenord via sops-nix
  sops.secrets.Dokument-backup-gocryptfs = {
    owner = "backups";
    group = "users";
    mode = "0400";
    path = "/home/backups/.gocryptfs-pass";
  };

  #### 🔁 Systemd-tjänst för gocryptfs + rsync
    systemd.services.rsyncnet-backup = {
      description = "Kryptera backup med gocryptfs och skicka till rsync.net";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "backups";
        Environment = "PATH=${lib.makeBinPath [ pkgs.gocryptfs pkgs.rsync pkgs.openssh pkgs.fuse ]}";
        ExecStart = ''
          set -euxo pipefail

          mkdir -p /home/backups/rsync-net-cipher

          # Mounta krypterad vy med lösenord från sops
          gocryptfs -reverse \
            -passfile /home/backups/.gocryptfs-pass \
            /home/backups/rsync-net/Dokument \
            /home/backups/rsync-net-cipher

          # Synka till rsync.net med privat nyckel
          rsync -az --delete \
            -e "ssh -i /home/backups/.ssh/id_ed25519" \
            /home/backups/rsync-net/Dokument \
            zh5530@zh5530.rsync.net:backups/

          # Avmontera krypterad vy
          fusermount -u /home/backups/rsync-net/Dokument
        '';
      };
    };

    #### ⏰ Timer för att köra tjänsten dagligen
    systemd.timers.rsyncnet-backup = {
      description = "Daglig rsync.net backup via gocryptfs";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };


  # Sanoid for zfs snapshots
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
