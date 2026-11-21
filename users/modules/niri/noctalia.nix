{ config, lib, ... }:

{
  programs.ghostty.settings.theme = lib.mkIf config.programs.ghostty.enable "noctalia";
  xdg.configFile."niri/shell.kdl".source = ./noctalia.kdl;
}
