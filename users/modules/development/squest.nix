{ pkgs, ... }:

let
  developmentShell = pkgs.mkShell {
    name = "squest";

    nativeBuildInputs = with pkgs; [
      python312
      poetry
      nodejs
      gcc
      pkg-config
      graphviz
    ];

    buildInputs = with pkgs; [
      mariadb
      postgresql
      sqlite
      openldap
      cyrus_sasl
      openssl
      libffi
      zlib
    ];

    # Keep Poetry's interpreter in the checkout for PyCharm to select.
    POETRY_VIRTUALENVS_IN_PROJECT = "true";

    # Support binary Python wheels that load native libraries at runtime.
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.mariadb
      pkgs.postgresql
      pkgs.sqlite
      pkgs.openldap
      pkgs.cyrus_sasl
      pkgs.openssl
      pkgs.libffi
      pkgs.zlib
    ];
  };
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "squest-shell";
      runtimeInputs = [ pkgs.nix ];
      text = ''
        # Keep the shell derivation without building every output of its inputs.
        exec nix-shell ${builtins.unsafeDiscardOutputDependency developmentShell.drvPath} "$@"
      '';
    })
  ];
}
