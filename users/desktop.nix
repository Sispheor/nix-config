{ config, inputs, lib, ... }:

{
  imports = [
    ./modules/niri
    inputs.nixdatifier.homeManagerModules.default
  ];

  programs.nixdatifier = {
    enable = true;
    autostart = true;
  };

  programs.ghostty.settings.theme = lib.mkIf config.programs.ghostty.enable "noctalia";

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
