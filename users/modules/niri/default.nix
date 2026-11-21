{ config, lib, pkgs, ... }:

{
  programs.ghostty.settings.theme = lib.mkIf config.programs.ghostty.enable "noctalia";

  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${./config.kdl}
        cp ${./config.kdl} $out
      '';
}
