{
  description = "My NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nur = {
    ## NUR Packages
    #url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules
    #};

    #nixgl = {
    ## OpenGL
    #url = "github:guibou/nixGL";
    #inputs.nixpkgs.follows = "nixpkgs";
    #};

    #nixos-generators = {
    #  url = "github:nix-community/nixos-generators";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-software-center.url = "github:vlinkz/nix-software-center";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    nixos-hardware,
    alejandra,
    nix-software-center,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";
  in rec {
    # Custom packages; acessible via 'nix build', 'nix shell', etc
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs;}
    );

    # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./shell.nix {inherit pkgs;}
    );

    # Default Formatter
    formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".alejandra);

    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    homeConfigurations = {
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      "juca@nitro" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = null;
          hostname = "nitro";
          username = "juca";
        };
        modules = [./home-manager];
      };

      "juca@nitrovoid" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = null;
          hostname = "nitro";
          username = "juca";
        };
        modules = [./home-manager];
      };

      "juca@DietPi" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = null;
          hostname = "DietPi";
          username = "juca";
        };
        modules = [./home-manager];
      };

      "juca@oldmac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "pantheon";
          hostname = "oldmac";
          username = "juca";
        };
        modules = [./home-manager];
      };

      "juca@mcbair" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "pantheon";
          hostname = "mcbair";
          username = "juca";
        };
        modules = [./home-manager];
      };

      "juca@note8" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = null;
          hostname = "note8";
          username = "juca";
        };
        modules = [./home-manager];
      };

      "juca@zed" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "pantheon";
          hostname = "zed";
          username = "juca";
        };
        modules = [./home-manager];
      };
    };

    # hostids are generated using `mkhostid` alias
    nixosConfigurations = {
      # nix build .#nixosConfigurations.iso.config.system.build.isoImage
      iso = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "pantheon";
          hostid = "09ac7fbb";
          hostname = "live";
          username = "nixos";
        };
        system = "x86_64-linux";
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix")
          ./nixos
        ];
      };

      nitro = nixpkgs.lib.nixosSystem {
        # sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        specialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "pantheon";
          hostid = "0145d776";
          hostname = "nitro";
          username = "juca";
        };
        modules = [./nixos];
      };

      raspberry = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs stateVersion;
          desktop = null;
          hostid = "445778b2";
          hostname = "raspberry";
          username = "juca";
        };
        modules = [./nixos];
      };

      oldmac = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "mate";
          hostid = "be4cb578";
          hostname = "oldmac";
          username = "juca";
        };
        modules = [./nixos];
      };

      mcbair = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs stateVersion;
          desktop = "mate";
          hostid = "b28460d8";
          hostname = "mcbair";
          username = "juca";
        };
        modules = [./nixos];
      };

      #note8 = nixpkgs.lib.nixosSystem {
      #  specialArgs = {
      #    inherit inputs outputs stateVersion;
      #    desktop = "pantheon";
      #    hostid = "37f0bf56";
      #    hostname = "note8";
      #    username = "juca";
      #  };
      #  modules = [./nixos];
      #};
    };
  };
}
