{ pkgs, ... }:

{
  imports = [
    ./medusa.nix
  ];

  programs.nix-ld.enable = true; # Support generic Linux executables

  # Resolve locally so test host overrides can be added without changing the
  # host's DNS settings. dnsmasq forwards all other requests to Cloudflare.
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
