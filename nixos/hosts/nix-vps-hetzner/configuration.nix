{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # networking
  systemd.network.enable = true;
  networking.hostName = "nix-vps-hetzner";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "sv_SE.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  
  # packages
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8OBmgPxRcvVdjXjXc+XGfVY2/zE1pqYM1VHkIqVOGf jt@nixos-t14"
  ];

  users.users.jt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8OBmgPxRcvVdjXjXc+XGfVY2/zE1pqYM1VHkIqVOGf jt@nixos-t14" 
    ];
    
  };

  # SSH-settings
  services.openssh = {
  	enable = true;
  	settings = {
  		PasswordAuthentication = false;
      PermitRootLogin = "yes";
  	};
  };

  # sudo
  security.sudo = {
  	enable = true;
  	wheelNeedsPassword = false;
  };

  # packages
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  # Workaround to get fish as the default interactive shell, and still using bash # Trying out with home-manager
  # as the system-shell
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.fish.enable = true;

  system.stateVersion = "25.05";
}
