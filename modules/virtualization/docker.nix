{ pkgs, user, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.docker-compose
  ];

  users.users.${user}.extraGroups = [ "docker" ];
}
