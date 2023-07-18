{
  description = "My NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-prev.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master"; # MacOS Package Management
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    #alejandra = {
    #  url = "github:kamadorueda/alejandra/3.0.0";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    nur = {
      # NUR Packages
      url =
        "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules
    };

    spicetify-nix.url = "github:the-argus/spicetify-nix";
    nixpkgs-f2k.url = "github:fortuneteller2k/nixpkgs-f2k";

    nixgl = {
      # OpenGL
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixos-generators = {
    #  url = "github:nix-community/nixos-generators";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    #nix-software-center.url = "github:vlinkz/nix-software-center";

    #emacs-overlay = {
    #  # Emacs Overlays
    #  url = "github:nix-community/emacs-overlay";
    #  flake = false;
    #};

    #doom-emacs = {
    #  # Nix-community Doom Emacs
    #  url = "github:nix-community/nix-doom-emacs";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.emacs-overlay.follows = "emacs-overlay";
    #};

    #hyprland = {
    #  # Official Hyprland flake
    #  url = "github:vaxerski/Hyprland"; # Add "hyprland.nixosModules.default" to the host modules
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #plasma-manager = {
    #  # KDE Plasma user settings
    #  url = "github:pjones/plasma-manager"; # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "nixpkgs";
    #};  
  };

  outputs = { self, nix-formatter-pack, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      libx = import ./lib {
        inherit inputs outputs home-manager nixpkgs stateVersion;
      };
    in
    {
      ### Home Manager config
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      # nix build .#homeConfigurations."juca@DietPi".activationPackage
      homeConfigurations = {
        ###.iso images ###
        "juca@iso-console" = libx.mkHome {
          hostname = "iso-console";
          username = "nixos";
        };
        "juca@iso-desktop" = libx.mkHome {
          hostname = "iso-desktop";
          username = "nixos";
          desktop = "pantheon";
        };
        ### Laptop ###
        "juca@nitro" = libx.mkHome {
          hostname = "nitro";
          username = "juca";
          desktop = "pantheon";
        };
        "junior@archnitro" = libx.mkHome {
          hostname = "archnitro";
          username = "junior";
        };
        "juca@air" = libx.mkHome {
          hostname = "air";
          username = "juca";
          desktop = "mate";
        };
        "juca@oldmac" = libx.mkHome {
          hostname = "oldmac";
          username = "juca";
          desktop = "pantheon";
        };
        ### VM testing ###
        "juca@vm" = libx.mkHome {
          hostname = "vm";
          username = "juca";
          desktop = "pantheon";
        };
        "juca@vm-mini" = libx.mkHome {
          hostname = "vm-mini";
          username = "juca";
        };
        ### Servers ###
        "juca@DietPi" = libx.mkHome {
          hostname = "DietPi";
          username = "juca";
        };
        "juca@rpi3" = libx.mkHome {
          hostname = "rpi3";
          username = "juca";
          desktop = "pantheon";
        };
        "juca@rpi3-mini" = libx.mkHome {
          hostname = "rpi3-mini";
          username = "juca";
        };
      };
      ### NixOS configs
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso|iso-mini}.config.system.build.isoImage
        iso-console = libx.mkHost {
          hostname = "iso-console";
          username = "nixos";
          hostid = "0145d780";
          installer = nixpkgs
            + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
        };
        iso-desktop = libx.mkHost {
          hostname = "iso-desktop";
          username = "nixos";
          hostid = "0145d783";
          installer = nixpkgs
            + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
          desktop = "pantheon";
        };
        # Laptop
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #  - nix build .#nixosConfigurations.vm.config.system.build.toplevel
        #nitro           = libx.mkHost {  hostname = "nitro";           username = "juca";  hostid = "0145d776"; desktop = "pantheon"; };
        air = libx.mkHost {
          hostname = "air";
          username = "juca";
          hostid = "b28460d8";
          desktop = "mate";
        };
        #oldmac          = libx.mkHost {  hostname = "oldmac";          username = "juca";  hostid = "be4cb578"; desktop = "pantheon"; };
        # Servers
        vm = libx.mkHost {
          hostname = "vm";
          username = "juca";
          hostid = "8c0b93a0";
          desktop = "pantheon";
        };
        #vm-mini        = libx.mkHost {  hostname = "vm-mini";         username = "juca";  hostid = "8c0b93a9"; };
        #pi              = libx.mkHost {  hostname = "rpi3";            username = "juca";  hostid = "8c0b93a2"; desktop = "pantheon"; };
        #pi-mini        = libx.mkHost {  hostname = "rpi3-mini";       username = "juca";  hostid = "8c0b93a5"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; });

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; });

      # Default Formatter
      # formatter = libx.forAllSystems (system: nixpkgs.legacyPackages."${system}".alejandra);

      # nix fmt
      formatter = libx.forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixfmt.enable = true;
            nixpkgs-fmt = {
              enable = true;
              #excludes = [ "./examples_helper/" ];
            };
            statix.enable = true;
          };
        });
    };
}
