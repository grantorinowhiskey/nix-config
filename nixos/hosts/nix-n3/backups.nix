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

  systemd.services."Dokument-backup-rsync-net" = {
    path = with pkgs; [ gocryptfs rsync openssh fuse];
    script = ''
      #!/usr/bin/env bash

      gocryptfs -reverse -passfile /home/backups/.gocryptfs-pass \
      /tank/backups/Dokument \
      /home/backups/rsync-net/Dokument &&

      rsync -avH -delete -e "ssh i /home/backups/.ssh/id_ed25519" \
      /home/backups/rsync-net/Dokument \
      zh5530@zh5530.rsync.net:backups/ &&

      fusermount -u /home/backups/rsync-net/Dokument
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "backups";
      RemainAfterExit = true;
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
