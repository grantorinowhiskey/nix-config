# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, programs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # zram
  zramSwap.enable = true;

  # hostname
  networking.hostName = "nix-t14";

  # Kernel, using latest
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Hardware accelerated video playback
  # nixpkgs.config.packageOverrides = pkgs: {
      # intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    # };
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        # libvdpau-va-gl
      ];
    };
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Virtualisation support
  virtualisation.libvirtd.enable = true;

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jt = {
    isNormalUser = true;
    description = "Jens";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Environment variable for text editor
  environment.variables = {
    EDITOR = "micro";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flake support and nix commandand-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   amberol
   aria2 # CLI-download manager
   bat
   bat-extras.batdiff
   bat-extras.batgrep
   bat-extras.batman
   bat-extras.batpipe
   bat-extras.batwatch
   bat-extras.prettybat
   bitwarden-cli
   bottom
   boxbuddy
   brave
   clapper
   curl
   discord
   disko
   distrobox
   element-desktop
   fastfetch
   fish
   fragments
   fzf
   git
   gnome.gnome-tweaks
   gnupg1
   gocryptfs
   htop
   hugo
   intel-gpu-tools
   inter # proposed font for gnome
   lm_sensors
   localsend
   micro
   mission-center
   mullvad-closest
   mullvad-vpn 
   nerdfonts
   nh
   nixos-generators
   obsidian 
   onlyoffice-bin_latest
   papirus-icon-theme
   ptyxis
   quickemu
   spotify
   starship
   svtplay-dl
   tealdeer
   vaults # GTK4 frontend for gocryptfs
   ventoy-full
   virt-manager
   vscodium # see below for extensions
   wget
   yt-dlp
   yubioath-flutter
   zellij

   # Unstable packages (disabled in flake for now)
   # unstablePackages.ladybird
   # unstablePackages.zed-editor

   # vscodium extensions
   (vscode-with-extensions.override {
       vscode = vscodium;
       vscodeExtensions = with vscode-extensions; [
         jnoortheen.nix-ide
         piousdeer.adwaita-theme
         ms-vscode-remote.remote-ssh
         ms-azuretools.vscode-docker
       ];
     })
  ];

  # List services that you want to enable:

  # Automatic upgrades
  # system.autoUpgrade = {
  # enable = true;
  # allowReboot = false;
  # operation = "boot";
  # };

  # Automatic garbage collection, per recommendations from the wiki
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
  };

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };
  # Enabling firmware updates
  services.fwupd.enable = true;

  # Flatpak support
  services.flatpak.enable = true;

  # Disable power profiles daemon to make sure auto-cpufreq starts at boot
  services.power-profiles-daemon.enable = false;

  # Enable pcscd for yubikey
  services.pcscd.enable = true;

  # tailscale
  services.tailscale.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable systemd-resolved
  services.resolved.enable = true;

  # Mullvad # Disabled since package not working under 24.05. Using wg cert in network manager
  services.mullvad-vpn.enable = true;

  # Syncthing, https://nixos.wiki/wiki/Syncthing
  services = {
    syncthing = {
        enable = true;
        user = "jt";
        dataDir = "/home/jt/";    # Default folder for new synced folders
        configDir = "/home/jt/.config/syncthing";   # Folder for Syncthing's settings and keys
        overrideDevices = true;     # overrides any devices added or deleted through the WebUI
        overrideFolders = true;     # overrides any folders added or deleted through the WebUI
        settings = {
          devices = {
            "pi" = { id = "EAY7MGV-4T44M7A-FNLKHD7-2IUMJV5-LXSV57E-736GQ6N-WJS2XOI-FQDUVQH"; };
            "desktop-archlinux" = { id = "DEVU2F6OP4-NGOV7GX-MN7B7OL-JQRXOEX-RDXS2GB-BMG3YLV-6IYXHB4-J4PFCAR"; };
          };
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 53317 ]; # Opened for localsend
  networking.firewall.allowedUDPPorts = [ 53317 ]; # Opened for localsend
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
      man = "batman --paging=always";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      nix_shell.heuristic = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
