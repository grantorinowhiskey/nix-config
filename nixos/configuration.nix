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

  boot.initrd.luks.devices."luks-c46c9934-00bf-4001-a5bd-064a22e1c674".device = "/dev/disk/by-uuid/c46c9934-00bf-4001-a5bd-064a22e1c674";
  networking.hostName = "nix-t14"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "se";
    xkbVariant = "";
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

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "jt";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   wget
   curl
   git
   micro
   fish
   starship
   blackbox-terminal
   yubioath-flutter
   nerdfonts
   intel-gpu-tools
   celluloid
   yt-dlp
   # obsidian # Electron EOL. Flatpak installed as a workaround
   discord
   fastfetch
   htop
   bottom
   lm_sensors
   papirus-icon-theme
   gnome.gnome-tweaks
   mission-center
   mullvad-vpn # needs systemd-resolved
   mullvad-closest
   vscodium # see below for extensions
   adw-gtk3
   element-desktop
   fragments
   libreoffice-fresh
   hunspellDicts.sv-se # hunspell dictionary for libreoffice
   zellij
   virt-manager       
   localsend
   fzf
   bat
   bat-extras.prettybat
   bat-extras.batwatch
   bat-extras.batpipe
   bat-extras.batman
   bat-extras.batgrep
   bat-extras.batdiff
   spotify
   distrobox
   ventoy-full
   tealdeer

   # vscodium extensions
   (vscode-with-extensions.override {
       vscode = vscodium;
       vscodeExtensions = with vscode-extensions; [
         jnoortheen.nix-ide
       ];
     })

   # gnome extensions
   gnomeExtensions.middle-click-to-close-in-overview
   gnomeExtensions.alphabetical-app-grid
   gnomeExtensions.blur-my-shell
   gnomeExtensions.caffeine
  ];

  # Exclusion of certain gnome applications
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-console    
  ]) ++ (with pkgs.gnome; [
    gnome-music
    # gedit # text editor
    epiphany # web browser
    geary # email reader
    # evince # document viewer
    gnome-characters
    totem # video player
    gnome-system-monitor
  ]);

  # Gnome triple buffering
  #
  nixpkgs.overlays = [
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs ( old: {
          src = pkgs.fetchgit {
            url = "https://gitlab.gnome.org/vanvugt/mutter.git";
            # GNOME 45: triple-buffering-v4-45
            rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
            sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
          };
        } );
      });
    })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Automatic upgrades
  system.autoUpgrade = {
  enable = true;
  allowReboot = false;
  operation = "boot";
  };
  
  # Automatic garbage collection, per recommendations from the wiki
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
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

  # Flatpak support. Obsidian installed with flatpak
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

  # Mullvad
  services.mullvad-vpn.enable = true;

  # Syncthing, https://nixos.wiki/wiki/Syncthing
  services = {
    syncthing = {
        enable = true;
        user = "jt";
        dataDir = "/home/jt/";    # Default folder for new synced folders
        configDir = "/home/jt/.config/syncthing";   # Folder for Syncthing's settings and keys
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
