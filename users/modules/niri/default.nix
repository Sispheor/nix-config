{ hostName, lib, pkgs, ... }:

{
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${./config.kdl}
        cp ${./config.kdl} $out
      '';

  xdg.configFile."niri/system.kdl".text = lib.optionalString (hostName == "nico-vm") ''
    debug {
        disable-cursor-plane
    }
  '';
}
