{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      # Configuration for host nix-t14
      nix-t14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
        modules = [
          ./nixos/hosts/nix-n3/configuration.nix
          ./nixos/hosts/nix-n3/hardware-configuration.nix
        ];
      };
    };
  };
}
