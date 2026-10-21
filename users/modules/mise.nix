{ ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    mutableSettings = true;

    # The host enables nix-ld for upstream Linux binaries.
    globalConfig.settings.python.compile = false;
  };
}
