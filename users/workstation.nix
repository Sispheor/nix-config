{ pkgs, inputs, ... }:

{
  imports = [
    ./modules/niri
    inputs.nixdatifier.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    gigolo
    nextcloud-client
  ];

  programs.nixdatifier = {
    enable = true;
    autostart = true;
  };

  programs.ghostty = {
    enable = true;
    settings = {
      gtk-single-instance = false;
      keybind = [
        "ctrl+shift+x=close_tab:this"
        "ctrl+shift+w=close_surface"
      ];
      theme = "noctalia";
    };
  };

  # Use the same standalone launch path as running Ghostty from a terminal.
  xdg.desktopEntries."com.mitchellh.ghostty" = {
    name = "Ghostty";
    comment = "A terminal emulator";
    exec = "ghostty --gtk-single-instance=false";
    icon = "com.mitchellh.ghostty";
    terminal = false;
    categories = [ "System" "TerminalEmulator" ];
    startupNotify = true;
    settings = {
      DBusActivatable = "false";
      StartupWMClass = "com.mitchellh.ghostty";
      X-GNOME-UsesNotifications = "true";
      X-TerminalArgExec = "-e";
      X-TerminalArgTitle = "--title=";
      X-TerminalArgAppId = "--class=";
      X-TerminalArgDir = "--working-directory=";
      X-TerminalArgHold = "--wait-after-command";
    };
    actions.new-window = {
      name = "New Window";
      exec = "ghostty --gtk-single-instance=false";
    };
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
