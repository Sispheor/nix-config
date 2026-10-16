{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bind
    binutils
    btop
    htop
    curl
    gcc
    git
    gnumake
    ipcalc
    jq
    ncdu
    nmap
    openldap
    pkg-config
    (python3.withPackages (ps: with ps; [
      requests
      psutil
      pyyaml
      rich
      sh
      pathspec
      beautifulsoup4
      python-dotenv
    ]))
    ripgrep
    tcpdump
    tree
    vim
    wget
  ];
}
