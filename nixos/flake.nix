{
  description = "A simple NixOS flake with multiple hosts";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Configuration for host nix-t14
      nix-t14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nix-t14/configuration.nix
          ./modules/gnome.nix
          ./modules/gaming.nix
        ];
      };

      # Configuration for another host nix-server
      nix-n3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nix-n3/configuration.nix
        ];
      };
    };
  };
}
