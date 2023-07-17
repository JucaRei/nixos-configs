{ pkgs, ... }:
pkgs.dockerTools.buildImage {
  name = "pivnet";
  tag = "latest";
  created = "now";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    pathsToLink = [ "/bin" ];

    paths = with pkgs; [
      # Common
      busybox
      curlFull
      cacert

      # Tools
      (callPackage ./pivnet.nix { })
    ];
  };

  config = {
    Entrypoint = [
      ""${REFERENCE_HERE}/bin/pivnet
      "
    ];
    Cmd = [
    ];
    ExposedPorts = {
    };
    Env = [
      "
      SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      "
    ];
    WorkingDir = "
      /workdir
      ";
  };
}
