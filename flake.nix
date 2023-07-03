{
  description = "My NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-prev.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #alejandra = {
    #  url = "github:kamadorueda/alejandra/3.0.0";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #nur = {
    ## NUR Packages
    #url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules
    #};

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
    nix-software-center.url = "github:vlinkz/nix-software-center";
  };

  outputs = { self, nixpkgs, disko, home-manager, nixos-hardware
    , nix-software-center, ... }@inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in {

      ### Home Manager config
      homeConfigurations = {
        # home-manager switch -b backup --flake $HOME/Zero/nix-config
        # nix build .#homeConfigurations."juca@DietPi".activationPackage
        "juca@iso"            = libx.mkHome { hostname = "iso";             username = "nixos"; desktop = "pantheon"; };
        "juca@iso-mini"       = libx.mkHome { hostname = "iso-mini";        username = "nixos"; };
        # Laptop
        "juca@nitro"          = libx.mkHome { hostname = "nitro";           username = "juca";  desktop = "pantheon"; };
        "juca@macbair"        = libx.mkHome { hostname = "macbair";         username = "juca";  desktop = "pantheon"; };
        "juca@oldmac"         = libx.mkHome { hostname = "oldmac";          username = "juca";  desktop = "pantheon"; };
        # VM testing
        "juca@vm"             = libx.mkHome { hostname = "vm";              username = "juca";  desktop = "xfce"; };
        #"juca@vm-mini"        = libx.mkHome { hostname = "vm-mini";         username = "juca"; };
        # Servers
        "juca@raspberry"      = libx.mkHome { hostname = "raspberry";       username = "juca";  desktop = "pantheon"; };
        "juca@DietPi"         = libx.mkHome { hostname = "DietPi";          username = "juca"; };
        "juca@raspberry-mini" = libx.mkHome { hostname = "raspberry-mini";  username = "juca"; };
      };

      ### NixOS configs
      nixosConfigurations = {
      # .iso images
      #  - nix build .#nixosConfigurations.{iso|iso-mini}.config.system.build.isoImage
      iso       = libx.mkHost { hostname = "iso";       username = "nixos"; hostid = "0145d780"; desktop = "pantheon";   installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; };
      #iso-mini  = libx.mkHost { hostname = "iso-mini";  username = "nixos"; hostid = "0145d783"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
      # Laptop
      #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
      #  - nix build .#nixosConfigurations.vm.config.system.build.toplevel
      nitro            = libx.mkHost { hostname = "nitro";            username = "juca"; desktop = "pantheon"; hostid = "0145d776"; };
      #macbair          = libx.mkHost { hostname = "macbair";          username = "juca"; desktop = "pantheon"; hostid = "b28460d8"; };
      oldmac           = libx.mkHost { hostname = "oldmac";           username = "juca"; desktop = "pantheon"; hostid = "be4cb578"; };
      vm               = libx.mkHost { hostname = "vm";               username = "juca"; desktop = "pantheon"; hostid = "8c0b93a0"; };
      # Servers
      #vm-mini          = libx.mkHost { hostname = "vm-mini";          username = "juca"; hostid = "8c0b93a9"; };
      raspberry        = libx.mkHost { hostname = "raspberry";        username = "juca"; desktop = "pantheon"; hostid = "8c0b93a2"; };
      #raspberry-mini   = libx.mkHost { hostname = "raspberry-mini";   username = "juca"; hostid = "8c0b93a5"; };
    };

    # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
    devShells = libx.forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in import ./shell.nix { inherit pkgs; }
    );

    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays { inherit inputs; };

    # Custom packages; acessible via 'nix build', 'nix shell', etc
    packages = libx.forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in import ./pkgs { inherit pkgs; }
    );

    # Default Formatter
    # formatter = libx.forAllSystems (system: nixpkgs.legacyPackages."${system}".alejandra);
  };
}
