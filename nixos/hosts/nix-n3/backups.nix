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

  # systemd-service to backup documents to rsync.net
  systemd.services.dokument-remote-backup = {
    description = "Upload Dokument backup to rsync.net";
    serviceConfig = {
      Type = "oneshot";
      User = "backups";
      ExecStart = ''
        ${pkgs.rsync}/bin/rsync -az --delete \
          -e "ssh -i /home/backups/.ssh/id_ed25519" \
          /tank/backups/Dokument/ \
          zh5530@zh5530.rsync.net:backups/Dokument/
      '';
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
