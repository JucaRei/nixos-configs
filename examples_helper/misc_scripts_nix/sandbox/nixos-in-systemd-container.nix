{pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz") {}}:
with pkgs; let
  init = pkgs.writeScript "init.sh" ''
    #!${pkgs.runtimeShell}
    /activate
    exec /run/current-system/systemd/lib/systemd/systemd $*
  '';

  config = {
    libs,
    pkgs,
    config,
    ...
  }: {
    boot = {
      loader.grub.devices = ["nodev"];
      isContainer = true;
    };
    fileSystems."/".device = "nodev";

    users = {
      mutableUsers = false;
      allowNoPasswordLogin = true;
    };

    time.timeZone = "Europe/Moscow";

    networking.useHostResolvConf = false;
    services.resolved.enable = true;

    services.rstudio-server = {
      enable = true;
      package = pkgs.rstudioServerWrapper.override {
        packages = with pkgs.rPackages; [
          tidyverse
          data_table
          shiny
        ];
      };
      serverWorkingDir = "/data";
      listenAddr = "0.0.0.0";
      rserverExtraConfig = ''
        auth-none=1
        auth-validate-users=0
        auth-encrypt-password=0
        auth-minimum-user-id=0
        server-daemonize=1
        server-pid-file=/var/run/rstudio-server/rstudio-server.pid
        www-port=8080
      '';
    };

    systemd.services.rstudio-server.serviceConfig.User = "rstudio-server";
    users.users.rstudio-server.home = "/data";

    system.stateVersion = "22.05";

    system.extraSystemBuilderCmds = ''
      ln -s ${init} $out/init.sh
      # /etc is a symlink, make a copy because systemd-nspawn breaks with symlinks
      ETC=$(readlink -f $out/etc)
      rm $out/etc
      cp -rf $ETC $out/etc
    '';
  };

  nixos = (pkgs.nixos config).toplevel;

  systemd-nspawn = pkgs.writeScript "nspawn.sh" ''
    #!${pkgs.runtimeShell}
    ROOT=${nixos}
    DATA=''${1:-.}
    TAG=''${2:-$RANDOM}
    ${pkgs.systemd}/bin/systemd-nspawn --machine $TAG \
        --bind-ro=/nix/store --bind=$(readlink -f $DATA):/data \
        --system-call-filter=@memlock \
        --overlay=+/etc::/etc --volatile=overlay --directory=$ROOT \
        /init.sh
  '';
in
  systemd-nspawn
## This is an example Nix derivation which creates a working systemd container with a working NixOS install inside.
## To launch the container you will need to run something like sudo $(nix-build nixos-in-systemd-container.nix)
## This example container is for setting up RStudio Server; you can customize the configuration to taste.
## The important bits to play nice with systemd-nspawn are a) the init.sh script and b) the extraSystemBuilderCmds.
## If you want to run the container non-interactively you can run this script with systemd-run or inside a systemd service.
## If you want to distribute these containers to another system you can use nix-copy-closure on the resulting script. (The target system must have nix installed.)

