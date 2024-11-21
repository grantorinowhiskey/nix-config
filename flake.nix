{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { nixpkgs, nixpkgs-unstable, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      # Configuration for host nix-t14
      nix-t14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./nixos/hosts/nix-t14/configuration.nix
          ./nixos/modules/gnome.nix
          ./nixos/modules/gaming.nix
          sops-nix.nixosModules.sops
        ];
      };

      # Configuration for another host nix-server
      nix-n3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./nixos/hosts/nix-n3/configuration.nix
          ./nixos/hosts/nix-n3/hardware-configuration.nix
          sops-nix.nixosModules.sops
          {
            
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              secrets = {
                "duckdns-token" = {};
              };
            };
          }
        ];
      };
    };
  };
}
