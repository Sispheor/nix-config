# flake/hosts.nix

{ inputs, ... }:

{
  flake.nixosConfigurations.perso =
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ../hosts/perso

        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit inputs;
          };

          home-manager.users.nico =
            import ../users/nico.nix;
        }
      ];
    };
}
