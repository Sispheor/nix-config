{ inputs }:

hostName:
{ system, user }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs hostName user;
  };

  modules = [
    (../hosts + "/${hostName}")

    inputs.home-manager.nixosModules.home-manager

    {
      networking.hostName = inputs.nixpkgs.lib.mkDefault hostName;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit inputs hostName user;
        };

        users.${user} = import (../users + "/${user}.nix");
      };
    }
  ];
}
