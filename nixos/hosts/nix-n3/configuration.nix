# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, nixpkgs-unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./services.nix # disabled for now since sonarr won't work. Leaning on docker instead.
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];
  services.zfs.autoScrub.enable = true;

  # zram
  zramSwap.enable = true;

  # networking
  networking.hostName = "nix-n3";
  networking.hostId = "7fc991b6";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  # hardware accelerated video
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = { # hardware.opengl in 24.05
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      onevpl-intel-gpu # QSV on 11th gen or newer
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "sv_SE.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "multimedia" "docker" ];
  };

  # sudo
  security.sudo = {
  	enable = true;
  	wheelNeedsPassword = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flake support and nix commandand-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alejandra
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
    intel-gpu-tools
    lm_sensors
    micro
    wget
    yazi
    zellij
  ];

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

  # List services that you want to enable:

  # docker
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
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

  # Enabling firmware updates
  services.fwupd.enable = true;

  # auto-cpufreq
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Enable thermald
  services.thermald.enable = true;

  # tailscale
  services.tailscale.enable = true;

  # firwall
  networking.firewall.allowedTCPPorts = [ 80 81 443 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
