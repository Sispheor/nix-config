# users/nico.nix

{ config, lib, pkgs, inputs, user, ... }:

{
  imports = [
    ./modules/development/tower-automation.nix
    ./modules/mise.nix
  #  ./modules/git.nix
  #  ./modules/shell.nix
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    govc
    k9s
    kubectl-df-pv
    kubectx
    kustomize
    mkcert
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

  home.activation.createKubeconfigDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.coreutils}/bin/mkdir -p -m 0700 ${lib.escapeShellArg "${config.home.homeDirectory}/.kube/kubeconfigs"}
  '';

  programs.kubeswitch = {
    enable = true;
    enableZshIntegration = true;
    commandName = "switch";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      for file in "$HOME"/Nextcloud/linux_config/bashrc.d/*.bashrc(N); do
        source "$file"
      done
    '';

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

  services.ssh-agent.enable = true;

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
