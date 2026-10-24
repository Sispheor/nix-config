{ pkgs, ... }:

{
  imports = [
    ./desktop/kde.nix
    ./desktop/niri.nix
    ./desktop/noctalia.nix
    ./medusa.nix
  ];

  programs.medusa.enable = true;
  programs.nix-ld.enable = true; # Support generic Linux executables

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Resolve locally so test host overrides can be added without changing the
  # desktop's DNS settings. dnsmasq forwards all other requests to Cloudflare.
  networking.nameservers = [ "127.0.0.1" ];
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      server = [ "1.1.1.1" "1.0.0.1" ];
      cache-size = 1000;
    };
  };

  environment.systemPackages = with pkgs; [
    vscode
    gitkraken
    pycharm
    ghostty
    firefox
  ];
}
