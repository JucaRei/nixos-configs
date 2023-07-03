{ config, lib, pkgs, ... }: {
  #https://nixos.wiki/wiki/Podman

  environment.systemPackages = with pkgs; [
    #buildah          # Container build tool
    #conmon           # Container monitoring
    #dive             # Container analyzer
    fuse-overlayfs # Container overlay+shiftfs
    #grype            # Container vulnerability scanner
    podman-compose
    podman-tui
    #skopeo           # Container registry utility
    #syft             # Container SBOM generator
  ];

  # podman-desktop; only if desktop defined.
  virtualisation = {
    podman = {
      defaultNetwork.settings = { dns_enabled = true; };
      #extraPackages = [ pkgs.zfs ];
      dockerCompat = true;
      enable = true;
      enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
    containers = {
      registries.search = [
        "docker.io"
        # "registry.fedoraproject.org"
        "quay.io"
        # "registry.access.redhat.com"
        # "registry.centos.org"
      ];
      containersConf.settings = {
        containers.dns_servers = [ "8.8.8.8" "8.8.4.4" ];
      };
    };
  };
}
