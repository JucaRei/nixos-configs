{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./xfce.nix
  ];

  # the rest of your nixos configuration
}
