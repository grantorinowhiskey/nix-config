{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # using nixos-unstable
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    sops-nix,
    disko,
    ...
  } @ inputs: {
    nixosConfigurations = {
      nix-t14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit (inputs) dms-plugin-registry;
        };

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

      nix-n3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./nixos/hosts/nix-n3/configuration.nix
          ./nixos/hosts/nix-n3/hardware-configuration.nix

          sops-nix.nixosModules.sops

          {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
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
