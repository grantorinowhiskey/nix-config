{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixos-unstable, ... }@inputs: {
    nixosConfigurations.nix-t14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix
        ./configuration.nix

        # Import the new GNOME module
        ./gnome.nix

        # Import gaming module
        ./gaming.nix

        {
          _module.args = { inherit inputs; };

          # Add an overlay to use nixos-unstable for select packages
          nixpkgs.overlays = [
            (final: prev: {
              unstablePackages = inputs.nixos-unstable.legacyPackages.${final.system};
            })
          ];
        }
      ];
    };
  };
}
