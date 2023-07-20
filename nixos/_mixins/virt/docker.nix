{
  lib,
  pkgs,
  hostname,
  ...
}: {
  virtualisation = {
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      enableOnBoot = lib.mkDefault false;
      enableNvidia = true;
      rootless = {
        enable = true;
        package = pkgs.docker;
      };
      autoPrune = {
        enable = true;
        dates = "monthly";
      };

      # https://docs.docker.com/build/buildkit/
      #daemon.settings = { "features" = { "buildkit" = true; }; };
      storageDriver = "overlay2";
    };
  };
  environment.systemPackages = with pkgs; [
    docker-machine
    docker-compose
    lazydocker
  ];
}
