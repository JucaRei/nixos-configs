{ pkgs, ... }:
let
  pivnet = callPackage ./pivnet.nix { };
in
pkgs.dockerTools.buildImage {
  name = "pivnet";
  tag = "latest";
  created = "now";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    pathsToLink = [ "/bin" ];

    paths =
      (with pkgs; [
        busybox
        curlFull
        cacert
      ])
      ++ [ pivnet ];
  };

  config = {
    Entrypoint = [
      "${pivnet}/bin/pivnet"
    ];
    Cmd = [
    ];
    ExposedPorts = { };
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    WorkingDir = "/workdir";
  };
}
