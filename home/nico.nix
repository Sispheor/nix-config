# home/nico.nix

{ config, pkgs, inputs,... }:

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

  programs.kitty = {
    enable = true;
    settings = {
      hide_window_decorations = "yes";
      include = "~/.config/kitty/themes/noctalia.conf";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Change ohMyZsh to oh-my-zsh
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "sudo"
      ];
    };
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.opencode = {
    enable = true;

    package =
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

    settings = {
      autoupdate = false;
    };
  };
}