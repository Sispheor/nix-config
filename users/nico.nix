# users/nico.nix

{ pkgs, inputs, ... }:

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

  home.packages = with pkgs; [
    bind
    binutils
    btop
    curl
    gcc
    gigolo
    gnumake
    govc
    ipcalc
    k9s
    kubectl-df-pv
    kubectx
    kubeswitch
    kustomize
    mkcert
    nmap
    nextcloud-client
    openldap
    pkg-config
    ripgrep
    tcpdump
    tree
  ];

  programs.git = {
    enable = true;
    ignores = [
      ".idea"
      "nico.py"
      "nico.go"
      "nico.sh"
      "nico.yml"
      "nico.yaml"
      "nico.json"
      ".vscode"
      "ansible.cfg"
    ];
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "yes";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
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
