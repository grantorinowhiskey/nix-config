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
      OnCalender = "daily";
      Persistent = true;
    };
    enable = true;
  };
}