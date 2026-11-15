{ pkgs, ... }:

{
  # KDE Plasma desktop
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtmultimedia
      qtvirtualkeyboard
    ];
  };

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "altgr-intl";

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override { embeddedTheme = "astronaut"; })
  ];

  services.desktopManager.plasma6.enable = true;
}
