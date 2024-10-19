# Template from https://github.com/nix-community/nixos-anywhere-examples/blob/main/configuration.nix
{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # zram
  zramSwap.enable = true;

  # hostname
  networking.hostName = "nix-n3";
  networking.hostId = "8425e349";


  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8OBmgPxRcvVdjXjXc+XGfVY2/zE1pqYM1VHkIqVOGf jt@nixos-t14"
  ];

  system.stateVersion = "24.05";
}