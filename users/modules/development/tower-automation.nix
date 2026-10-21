{ pkgs, ... }:

let
  developmentShell = pkgs.mkShell {
    name = "tower-automation";

    # mise supplies Python and the project's virtualenv.
    nativeBuildInputs = with pkgs; [
      mise
      gcc
      pkg-config
    ];

    buildInputs = with pkgs; [
      openssl
      libffi
      openldap
      cyrus_sasl
      zlib
    ];

    # Support binary wheels that expect common libraries at runtime.
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.openssl
      pkgs.libffi
      pkgs.openldap
      pkgs.cyrus_sasl
      pkgs.zlib
    ];

    MISE_PYTHON_COMPILE = "false";

    shellHook = ''
      eval "$(mise activate bash)"
    '';
  };
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "tower-automation-shell";
      runtimeInputs = [ pkgs.nix ];
      text = ''
        # Keep the shell derivation without building every output of its inputs.
        exec nix-shell ${builtins.unsafeDiscardOutputDependency developmentShell.drvPath} "$@"
      '';
    })
  ];
}
