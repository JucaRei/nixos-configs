{ config, desktop, lib, outputs, inputs, pkgs, stateVersion, username, ... }:
let inherit (pkgs.stdenv) isDarwin;
in {
  # Only import desktop configuration if the host is desktop enabled
  # Only import user specific configuration if they have bespoke settings
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    #./_mixins/dev
    ./_mixins/console
  ] ++ lib.optional (builtins.isString desktop) ./_mixins/desktop
    ++ lib.optional (builtins.isPath (./. + "/_mixins/users/${username}"))
    ./_mixins/users/${username};

  home = {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory =
      if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
    inherit stateVersion;
    inherit username;
  };

  nixpkgs = {
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
      allowUnsupportedSystem = true;
      #allowBroken = true;
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
    settings.keep-going = false;

    package = lib.mkDefault pkgs.unstable.nix;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      nix-path = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
        config.nix.registry;
      warn-dirty = false;
      max-jobs = "auto";
      sandbox = true;
      #trusted-users = [ "@nixbld" "@wheel" ];
    };

    extraOptions = ''
      keep-outputs          = true
      keep-derivations      = false

      # Free up to 1GiB whenever there is less than 100MiB left.
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      connect-timeout = 5
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
