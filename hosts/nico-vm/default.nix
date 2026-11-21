{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/gnome.nix
    ../../modules/desktop/dms.nix
    ../../modules/virtualization/docker.nix
    ../../modules/virtualization/vmware.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Keep the version used by the fresh installation; review it before rebuilding.
  system.stateVersion = "26.05";
}
