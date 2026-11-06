{ config, inputs, lib, ... }:

{
  imports = [
    inputs.clipway.nixosModules.default
  ];

  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest.headless = false;

  # Temporary workaround for https://github.com/NixOS/nixpkgs/pull/581265.
  # Remove when nixpkgs uses fuse3 for the VMware vmblock mount.
  systemd.units."run-vmblock\\x2dfuse.mount".text = lib.mkForce ''
    [Unit]
    ConditionVirtualization=vmware
    Description=VMware vmblock fuse mount
    Documentation=https://github.com/vmware/open-vm-tools/blob/master/open-vm-tools/vmblock-fuse/design.txt

    [Mount]
    What=${lib.getExe' config.virtualisation.vmware.guest.package "vmware-vmblock-fuse"}
    Where=/run/vmblock-fuse
    Type=fuse3
    Options=subtype=vmware-vmblock,default_permissions,allow_other
  '';

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
