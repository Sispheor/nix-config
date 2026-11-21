{ inputs, user, ... }:

{
  imports = [
    ./niri.nix
    inputs.noctalia.nixosModules.default
  ];

  home-manager.users.${user}.imports = [
    ../../users/modules/niri
    ../../users/modules/niri/noctalia.nix
  ];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };
}
