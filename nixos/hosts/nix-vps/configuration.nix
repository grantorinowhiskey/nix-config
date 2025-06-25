{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # hostname
  networking.hostName = "nix-vps";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "sv_SE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  environment.systemPackages = with pkgs; [
    aria2
    bat
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batpipe
    bat-extras.batwatch
    bat-extras.prettybat
    bottom
    curl
    fastfetch
    fish
    fzf
    git
    gocryptfs
    htop
    lazygit
    micro
    wget
    yazi
    zellij
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # my ssh-key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8OBmgPxRcvVdjXjXc+XGfVY2/zE1pqYM1VHkIqVOGf jt@nixos-t14"
  ];

  users.users.jt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8OBmgPxRcvVdjXjXc+XGfVY2/zE1pqYM1VHkIqVOGf jt@nixos-t14"
    ];
  };

  # Workaround to get fish as the default interactive shell, and still using bash
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

  programs.fish = {
    enable = true;
    shellAliases = {
      man = "batman";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      nix_shell.heuristic = true;
    };
  };

  # Automatic garbage collection, per recommendations from the wiki
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
  };

  # SSH-settings
  services.openssh = {
  	enable = true;
  	settings = {
  		PasswordAuthentication = false;
      PermitRootLogin = "yes";
  	};
  };

  # services


  # firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [  ];
  };

  system.stateVersion = "25.05";
}
