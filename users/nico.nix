# users/nico.nix

{ config, lib, pkgs, inputs, user, ... }:

{
  imports = [
    ./modules/niri
    inputs.nixdatifier.homeManagerModules.default
  #  ./modules/git.nix
  #  ./modules/shell.nix
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  programs.nixdatifier = {
    enable = true;
    autostart = true;
  };

  home.packages = with pkgs; [
    gigolo
    govc
    k9s
    kubectl-df-pv
    kubectx
    kustomize
    mkcert
    nextcloud-client
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

  programs.ghostty = {
    enable = true;
    settings = {
      gtk-single-instance = false;
      keybind = [
        "ctrl+shift+x=close_tab:this"
        "ctrl+shift+w=close_surface"
      ];
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

  programs.kitty = {
    enable = true;
    settings = {
      hide_window_decorations = "yes";
      include = "~/.config/kitty/themes/noctalia.conf";
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

    shellAliases = {
      k = "kubectl";
      s = ''switch --kubeconfig-path $HOME/.kube/kubeconfigs --kubeconfig-name "*.kubeconfig"'';
    };

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
