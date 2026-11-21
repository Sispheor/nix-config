{ inputs, user, ... }:

{
  imports = [
    ./niri.nix
    inputs.dms.nixosModules.dank-material-shell
  ];

  home-manager.users.${user}.imports = [
    ../../users/modules/niri
    ../../users/modules/niri/dms.nix
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      target = "niri.service";
    };
  };
}
