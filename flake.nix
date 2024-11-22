{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    # old package for sonarr
    nixpkgs-e08a8231.url = "github:NixOS/nixpkgs/e08a8231e2c827f586e64727c1063c5e61dbc00d";
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixpkgs-e08a8231, sops-nix, ... }@inputs: {
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
          nixpkgs-e08a8231 = import nixpkgs-e08a8231 {
            system = "x86_64-linux";
            configallowUnfree = true;
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
