{
  description = "Bergmann's system configurations and modules";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin (for MacOS machines)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
  };

  outputs = {
    self,
    darwin,
    home-manager,
    nix-homebrew,
    disko,
    nixpkgs,
    ...
  } @ inputs: let 
    inherit (self) outputs;

    # Define user configurations
    users = {
      bergmannlucas = {
        email = "bergmannlcs@proton.me";
        fullName = "Lucas Bergmann";
        name = "bergmannlucas";
      };
    };

    # Function for NixOS system configuration
    mkNixosConfiguration = hostname: username:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
        };
        modules = [
          # ./hosts/${hostname}/configuration.nix
          ./hosts/${hostname}
          inputs.disko.nixosModules.disko
        ];
      };

    # Function for nix-darwin system configuration
    mkDarwinConfiguration = hostname: username:
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
        };
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };

    # Function for Home Manager configuration
    mkHomeConfiguration = system: username: hostname:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        extraSpecialArgs = {
          inherit inputs outputs;
          userConfig = users.${username};
        };
        modules = [
          ./home/${username}/${hostname}.nix
        ];
      };
  in {
    nixosConfigurations = {
      kazordoon = mkNixosConfiguration "kazordoon" "bergmannlucas";
    };

    darwinConfigurations = {
      air = mkDarwinConfiguration "air" "bergmannlucas";
    };

    homeConfigurations = {
      "bergmannlucas@kazordoon" = mkHomeConfiguration "x86_64-linux" "bergmannlucas" "kazordoon";
    };

    overlays = import ./overlays {inherit inputs;};
  };
}
