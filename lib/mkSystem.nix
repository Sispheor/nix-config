{ inputs }:

hostName:
{ system, user, workstation ? false, desktop ? false }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs hostName user;
  };

  modules = [
    ../modules/common.nix
    (../hosts + "/${hostName}")
    inputs.home-manager.nixosModules.home-manager
  ]
  ++ inputs.nixpkgs.lib.optional workstation ../modules/workstation.nix
  ++ inputs.nixpkgs.lib.optional desktop ../modules/desktop.nix
  ++ [
    {
      networking.hostName = inputs.nixpkgs.lib.mkDefault hostName;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit inputs hostName user;
        };

        users.${user}.imports = [
          (../users + "/${user}.nix")
        ]
        ++ inputs.nixpkgs.lib.optional workstation ../users/workstation.nix
        ++ inputs.nixpkgs.lib.optional desktop ../users/desktop.nix;
      };
    }
  ];
}
