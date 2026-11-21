{ inputs, user, ... }:

{
  imports = [
    ./niri.nix
    inputs.noctalia.nixosModules.default
  ];

  home-manager.users.${user}.imports = [
    ../../users/modules/niri
  ];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };
}
