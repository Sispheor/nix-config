{ config, lib, pkgs, ... }:

let
  cfg = config.programs.medusa;
  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "medusa-vault";
    version = "0.7.3";

    src = pkgs.fetchurl {
      url = "https://github.com/jonasvinther/medusa/releases/download/v0.7.3/medusa_0.7.3_linux_amd64.tar.gz";
      hash = "sha256-BNk3jmxxflf3oT3fhUdlrQzLTNOP2j2uT5tgsTxGiFQ=";
    };

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 medusa $out/bin/medusa
    '';

    meta = {
      description = "CLI tool for importing and exporting HashiCorp Vault secrets";
      homepage = "https://github.com/jonasvinther/medusa";
      license = lib.licenses.mit;
      mainProgram = "medusa";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  options.programs.medusa.enable = lib.mkEnableOption "the Medusa Vault CLI";

  config = {
    programs.medusa.enable = true;
    environment.systemPackages = lib.mkIf cfg.enable [ package ];
  };
}
