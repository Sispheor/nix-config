{ inputs, ... }:

{
  imports = [
    inputs.nixdatifier.homeManagerModules.default
  ];

  programs.nixdatifier = {
    enable = true;
    autostart = true;
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
