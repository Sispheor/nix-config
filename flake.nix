{
  description = "Nicolas' NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clipway.url = "github:krisztianfekete/clipway";

    nixdatifier = {
      url = "github:Muddyblack/nixdatifier";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
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
        appart = mkSystem "appart" {
          system = "x86_64-linux";
          user = "nico";
          workstation = true;
          desktop = true;
        };
        hpe = mkSystem "hpe" {
          system = "x86_64-linux";
          user = "nico";
          workstation = true;
          desktop = true;
        };
      };
    };
}
