{ config, desktop, hostname,
#, hostid
inputs, lib, modulesPath, outputs, pkgs, stateVersion, username, ... }:
#let
#machines = ["nitro" "air"];
#in
{
  # Import host specific boot and hardware configurations.
  # Only include desktop components if one is supplied.
  # - https://nixos.wiki/wiki/Nix_Language:_Tips_%26_Tricks#Coercing_a_relative_path_with_interpolated_variables_to_an_absolute_path_.28for_imports.29
  imports = [
    #(./. + "/${hostname}/disks.nix")
    #(./. + "/${hostname}/hardware.nix")
    #(./. + "/${hostname}/boot.nix")

    #inputs.disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (./. + "/${hostname}")
    ./_mixins/shared

  ]
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/disks.nix")) ./${hostname}/disks.nix
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/disks.nix")) (import ./${hostname}/disks.nix { })
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/extra.nix")) (import ./${hostname}/extra.nix { })
  #++ lib.optional (builtins.elem hostname machines) ./_mixins/hardware/gfx-intel.nix
    ++ lib.optional (builtins.isString desktop) ./_mixins/desktop;

  # Only install the docs I use
  documentation = {
    enable = true; # documentation of packages
    nixos.enable = false; # nixos documentation
    man.enable = true; # man pages and the man command
    info.enable = false; # info pages and the info command
    doc.enable = false;
  };

  # Use passed hostname to configure basic networking
  networking = {
    hostName = hostname;
    #hostId = hostid;
    useDHCP = lib.mkDefault true;
  };

  ###################
  ### NixPackages ###
  ###################

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # if you also want support for flakes
      #(self: super: {
      #  nix-direnv = super.nix-direnv.override { enableFlakes = true; };
      #})
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
      allowUnsupportedSystem = true;
      # Disable broken package
      allowBroken = false;
      # Disable if you don't want unfree packages
      allowUnfree = true;

      ### Allow old broken electron
      permittedInsecurePackages = lib.singleton "electron-12.2.3";

      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  #####################
  ### Nixos Configs ###
  #####################

  nix = {
    checkConfig = true;
    checkAllErrors = true;

    # Reduce disk usage
    daemonIOSchedClass = "idle";
    # Leave nix builds as a background task
    daemonCPUSchedPolicy = "idle";

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

    optimise = {
      automatic = true;
      dates = [ "00:00" "05:00" "12:00" "21:00" ];
    };
    package = pkgs.unstable.nix;
    #package = pkgs.nixFlakes;
    settings = {
      sandbox = false;
      #sandbox = relaxed;
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];

      # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
      keep-going = false;

      # Allow to run nix
      #allowed-users = [ "${username}" "wheel" ];
    };
  };

  system.stateVersion = stateVersion;
}
