# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, nixpkgs-unstable, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # zram
  zramSwap.enable = true;

  # hostname
  networking.hostName = "nix-t14";

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

  # Hardware accelerated video playback
  # nixpkgs.config.packageOverrides = pkgs: {
  # intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    packages = with pkgs; [
      firefox
    ];
  };

  # Environment variable for text editor
  # environment.variables = {
  #   EDITOR = "micro";
  # };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flake support and nix commandand-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Packages installed in system profile
  environment.systemPackages = with pkgs; [
    alejandra
    amberol
    aria2
    # bat
    # bat-extras.batdiff
    # bat-extras.batgrep
    # bat-extras.batman
    # bat-extras.batpipe
    # bat-extras.batwatch
    # bat-extras.prettybat
    bitwarden-cli
    bottom
    boxbuddy
    brave
    buffer
    celluloid
    curl
    discord
    disko
    distrobox
    element-desktop
    fastfetch
    ffmpeg-full
    # fish # Trying out with home-manager
    fragments
    fzf
    git
    gnupg1
    gocryptfs
    home-manager
    htop
    hugo
    imagemagick
    impression
    intel-gpu-tools
    inter
    jellyfin-media-player
    lazydocker
    lazygit
    lm_sensors
    # localsend
    logseq
    # micro
    mission-center
    morewaita-icon-theme
    mpv
    mullvad-closest
    mullvad-vpn
    nh
    nixd
    nixos-generators
    nixos-shell
    onlyoffice-desktopeditors
    papirus-icon-theme
    ptyxis
    quickemu
    quickgui
    resources
    sops
    spotify
    sshfs
    ssh-to-age
    starship
    svtplay-dl
    tealdeer
    vaults
    virt-manager
    vscodium # see below for extensions
    wget
    wl-clipboard-rs
    # yazi
    yubioath-flutter
    zellij

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

    # unstable packages
    nixpkgs-unstable.ghostty
    nixpkgs-unstable.yt-dlp
    nixpkgs-unstable.zed-editor
    nixpkgs-unstable.obsidian
  ];

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.roboto-mono
    nerd-fonts.hack
  ];

  # nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # Recommended for nixd language server. Disabled for now, don't understand.

  # List services that you want to enable:

  # Automatic garbage collection, per recommendations from the wiki
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
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
  services.tailscale = {
    enable = true;
    package = nixpkgs-unstable.tailscale;
  };

  # davfs2, to mount taildrive shares
  services.davfs2.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable systemd-resolved
  services.resolved.enable = true;

  # Mullvad
  services.mullvad-vpn.enable = true;

  # Disabled syncthing to not conflict with livesync.
  # Syncthing, https://nixos.wiki/wiki/Syncthing
  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #   user = "jt";
  #   dataDir = "/home/jt/";    # Default folder for new synced folders
  #   configDir = "/home/jt/.config/syncthing";   # Folder for Syncthing's settings and keys
  #   overrideDevices = true;     # overrides any devices added or deleted through the WebUI
  #   overrideFolders = false;     # overrides any folders added or deleted through the WebUI
  #   settings = {
  #     devices = {
  #       "nix-n3" = { id = "JJEWJLR-NCTFT23-TVFKJN2-7ZPO67M-2IRXVKQ-FGUST4P-AMTTZ5Y-N7J7OA4"; };
  #       "desktop-archlinux" = { id = "U2F6OP4-NGOV7GX-MN7B7OL-JQRXOEX-RDXS2GB-BMG3YLV-6IYXHB4-J4PFCAR"; };
  #     };
  #   };
  # };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ]; # Opened for localsend
    allowedUDPPorts = [ 53317 ]; # Opened for localsend
  };

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

  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     nix_shell.heuristic = true; # Provides a nix shell prompt in nix shell
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
