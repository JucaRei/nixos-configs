{
  pkgs,
  lib,
  config,
  ...
}:
with pkgs;
with lib;
with builtins; let
  cfg = config.sys;
in {
  options.sys.virtualisation = {
    docker = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enables docker";
      };
      enableOnBoot = mkOption {
        type = types.bool;
        default = true;
        description = "Enables docker on boot";
      };
      autoPrune = {
        type = types.bool;
        default = false;
        description = "Prune all automatic";
      };
    };
  };

  config = {
    virtualisation.docker.enable = cfg.virtualisation.docker.enable;
    virtualisation.docker.storageDriver = "overlay2";
  };

  # Add docker extensions.
  environment.systemPackages = [
    #pkgs.docker-compose
    pkgs.docker-machine
  ];
}
