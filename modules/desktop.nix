{ ... }:

{
  imports = [
    ./desktop/kde.nix
    ./desktop/niri.nix
    ./desktop/noctalia.nix
  ];

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
}
