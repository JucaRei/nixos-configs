{ lib, ... }: {
  imports =
    [ ../../../services/syncthing.nix ../../../services/mpris-proxy.nix ];
  services.kbfs.enable = lib.mkForce false;
}
