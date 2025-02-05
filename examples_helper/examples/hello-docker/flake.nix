{
  inputs = {mrkuz.url = "github:mrkuz/nixos";};
  outputs = {mrkuz}: let
    system = "x86_64-linux";
    pkgs = mrkuz.utils.mkPkgs system;
  in {
    defaultPackage."${system}" = pkgs.dockerTools.buildImage {
      name = "hello-docker";
      tag = "latest";
      copyToRoot = pkgs.buildEnv {
        name = "image-root";
        paths = [pkgs.busybox];
        pathsToLink = ["/bin"];
        # extraOutputsToInstall = [ "bin" ];
      };
      runAsRoot = ''
        install -m 777 -d /tmp
      '';
      config = {Cmd = ["${pkgs.busybox}/bin/sh"];};
    };
  };
}
