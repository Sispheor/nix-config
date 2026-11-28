{ pkgs, lib, ... }:

{
  programs.niri.enable = true;

  # Prefer Niri while keeping GNOME available as a fallback session.
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
