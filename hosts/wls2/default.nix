{ inputs, lib, user, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = user;
  };

  # WSL manages interfaces and DNS, including Windows/VPN DNS integration.
  networking.networkmanager.enable = lib.mkForce false;
  networking.nameservers = lib.mkForce [ ];
  services.dnsmasq.enable = lib.mkForce false;

  system.stateVersion = "26.05";
}
