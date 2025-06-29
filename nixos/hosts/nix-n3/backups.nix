{ config, pkgs, lib, ... }:

{
  #### 📁 Lokal backup från Syncthing till ZFS
  systemd.services.dokument-backup = {
    description = "Backup Syncthing Documents till ZFS";
    serviceConfig = {
      Type = "oneshot";
      User = "jt";
      ExecStart = "${pkgs.rsync}/bin/rsync -avz --delete /home/jt/appdata/syncthing/data/Dokument/ /tank/backups/Dokument/";
    };
  };

  systemd.timers.dokument-backup = {
    description = "Timer för lokal Dokument-backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
    };
  };

  #### 🔐 Gocryptfs-lösenord via sops
  sops.secrets.Dokument-backup-gocryptfs = {
    owner = "backups";
    group = "users";
    mode = "0400";
    path = "/home/backups/.gocryptfs-pass";
  };

  #### 🔁 Krypterad backup till rsync.net
  systemd.services.rsyncnet-backup = {
    description = "Kryptera backup med gocryptfs och skicka till rsync.net";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "backups";
      Environment = "PATH=${lib.makeBinPath [ pkgs.gocryptfs pkgs.rsync pkgs.openssh pkgs.fuse ]}";
    };

    script = ''
      set -euxo pipefail

      # Förbered krypterad mountpunkt
      mkdir -p /home/backups/rsync-net/Dokument

      # Mounta krypterad vy direkt till målmappen
      gocryptfs -reverse \
        -passfile /home/backups/.gocryptfs-pass \
        /tank/backups/Dokument \
        /home/backups/rsync-net/Dokument

      # Rsync krypterad vy
      rsync -az --delete \
        -e "ssh -i /home/backups/.ssh/id_ed25519" \
        /home/backups/rsync-net/Dokument/ \
        zh5530@zh5530.rsync.net:backups/Dokument/

      # Avmontera
      fusermount -u /home/backups/rsync-net/Dokument
    '';
  };

  systemd.timers.rsyncnet-backup = {
    description = "Daglig rsync.net-backup (krypterad)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  #### 💾 Snapshot-hantering med Sanoid
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
