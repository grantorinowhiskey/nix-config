{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # disko.url = "github:nix-community/disko";
    # disko.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Configuration for host nix-t14
      nix-t14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/nix-t14/configuration.nix
          ./nixos/modules/gnome.nix
          ./nixos/modules/gaming.nix
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
