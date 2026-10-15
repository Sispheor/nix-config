{ pkgs, lib, ... }:

{
  programs.niri.enable = true;

  # Both Plasma and Niri define a default session.
  # Explicitly prefer Niri while keeping Plasma available in the greeter.
  services.displayManager.defaultSession = lib.mkForce "niri";

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    fuzzel
    playerctl
    swaylock
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
