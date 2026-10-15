{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bind
    binutils
    btop
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
    ripgrep
    tcpdump
    tree
    vim
    wget
  ];
}
