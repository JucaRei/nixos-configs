{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs
, stateVersion, username, ... }: {
  # Import host specific boot and hardware configurations.
  # Only include desktop components if one is supplied.
  # - https://nixos.wiki/wiki/Nix_Language:_Tips_%26_Tricks#Coercing_a_relative_path_with_interpolated_variables_to_an_absolute_path_.28for_imports.29
  imports = [
    #(./. + "/${hostname}/disks.nix")

    #inputs.disko.nixosModules.disko    
    (modulesPath + "/installer/scan/not-detected.nix")
    #./${hostname}
    (./. + "/${hostname}/boot.nix")
    (./. + "/${hostname}/hardware.nix")
    ./_mixins/base
    ./_mixins/services/kmscon.nix
    ./_mixins/services/fwupd.nix
    ./_mixins/users/root
    ./_mixins/users/${username}
  ]
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/disks.nix")) ./${hostname}/disks.nix

  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/disks.nix")) (import ./${hostname}/disks.nix { })
    ++ lib.optional (builtins.pathExists (./. + "/${hostname}/extra.nix"))
    (import ./${hostname}/extra.nix { })
    ++ lib.optional (builtins.isString desktop) ./_mixins/desktop;

  nixpkgs = {

    ### Allow old broken electron 
    config.permittedInsecurePackages = lib.singleton "electron-12.2.3";

    config.android_sdk.accept_license = true;

    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Allow unsupported packages to be built
      allowUnsupportedSystem = false;
      # Disable broken package
      allowBroken = false;
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {

    # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
    settings.keep-going = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
      dates = "00:00";
    };

    extraOptions = ''
      log-lines = 15

      # Free up to 4GiB whenever there is less than 1GiB left.
      min-free = ${toString (1024 * 1024 * 1024)}
      # Free up to 4GiB whenever there is less than 512MiB left.
      #min-free = ${toString (512 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
      #min-free = 1073741824 # 1GiB
      #max-free = 4294967296 # 4GiB
      #builders-use-substitutes = true
    '';

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;
    optimise.automatic = true;
    #package = pkgs.unstable.nix;
    package = pkgs.nixFlakes;
    settings = {
      sandbox = "relaxed";
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    };
  };

  system.stateVersion = stateVersion;
}
