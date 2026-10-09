# home/nico.nix

{ config, pkgs, ... }:

{
  imports = [
    ./modules/niri
  #  ./modules/git.nix
  #  ./modules/shell.nix
  ];

  home.username = "nico";
  home.homeDirectory = "/home/nico";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name  = "Nicolas Marcq";
      email = "nico.marcq@gmail.com";
    };
  };
}