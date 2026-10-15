{ inputs, ... }:

{
  imports = [
    inputs.clipway.nixosModules.default
  ];

  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest.headless = false;

  services.clipway = {
    enable = true;
    # target = "plasma-workspace-wayland.target";
    target = "graphical-session.target";
  };

  hardware.graphics = {
    enable = true; # enables the system graphics driver infrastructure
    enable32Bit = true;
  };

}
