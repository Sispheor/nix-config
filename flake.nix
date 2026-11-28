{
  description = "Nicolas' NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clipway.url = "github:krisztianfekete/clipway";

    nixdatifier = {
      url = "github:Muddyblack/nixdatifier";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs:
    let
      mkSystem = import ./lib/mkSystem.nix { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nico-vm = mkSystem "nico-vm" {
          system = "x86_64-linux";
          user = "nico";
          workstation = true;
          desktop = true;
        };
      };
    };
}
