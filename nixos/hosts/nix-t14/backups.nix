{ pkgs, ... }:

{
  systemd.services.anteckningar-backup = {
    description = "Backup av Anteckningar till nix-n3";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = with pkgs; [
      openssh
      rsync
    ];

    script = ''
      set -eu

      ssh \
        -o BatchMode=yes \
        -o ConnectTimeout=30 \
        jt@nix-n3 \
        mkdir -p /tank/backups/Anteckningar

      rsync \
        --archive \
        --partial \
        --dry-run \
        --itemize-changes \
        --delete-delay \
        --max-delete=100 \
        -e "ssh -o BatchMode=yes -o ConnectTimeout=30" \
        /home/jt/Anteckningar/ \
        jt@nix-n3:/tank/backups/Anteckningar/
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "jt";
      UMask = "0077";
    };
  };

  systemd.timers.anteckningar-backup = {
    description = "Kör backup av Anteckningar var 15:e minut";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "15min";
      Persistent = true;
      Unit = "anteckningar-backup.service";
    };
  };
}
