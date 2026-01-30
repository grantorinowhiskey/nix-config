{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # using nixos-unstable
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    copyparty.url = "github:9001/copyparty";
  };

  outputs =
    {
      nixpkgs,
      # nixpkgs-unstable,
      sops-nix,
      disko,
      copyparty,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # Configuration for host nix-t14
        nix-t14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          # specialArgs = {
          #   nixpkgs-unstable = import nixpkgs-unstable {
          #     system = "x86_64-linux";
          #     config.allowUnfree = true;
          #   };

          modules = [
            ./nixos/hosts/nix-t14/configuration.nix
            ./nixos/modules/gnome.nix
            ./nixos/modules/gaming.nix
            ./nixos/modules/niri.nix
            sops-nix.nixosModules.sops
            {
              sops = {
                defaultSopsFile = ./secrets/secrets.yaml;
                age.keyFile = "/home/jt/.config/sops/age/keys.txt";
                secrets = {
                  dokument-crypt = {
                    owner = "jt";
                  };
                };
              };
            }
          ];
        };

        # Configuration for another host nix-server
        nix-n3 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          # specialArgs = {
          #   nixpkgs-unstable = import nixpkgs-unstable {
          #     system = "x86_64-linux";
          #     config.allowUnfree = true;
          #   };

          modules = [
            ./nixos/hosts/nix-n3/configuration.nix
            ./nixos/hosts/nix-n3/hardware-configuration.nix
            copyparty.nixosModules.default

            (
              { ... }:
              {
                nixpkgs.overlays = [
                  copyparty.overlays.default
                ];
              }
            )

            sops-nix.nixosModules.sops

            {

              sops = {
                defaultSopsFile = ./secrets/secrets.yaml;
                age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
                secrets = {
                  "copyparty-jt-password" = {
                    owner = "copyparty";
                  };
                };
              };
            }
          ];
        };
        nix-vps = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nixos/hosts/nix-vps/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
        nix-vps-hetzner = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nixos/hosts/nix-vps/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
