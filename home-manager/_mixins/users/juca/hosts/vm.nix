{ lib, ... }:
with lib.hm.gvariant;
{
  imports =
    [
      ../../../services/keybase.nix
      ../../../services/maestral.nix
      ../../../services/syncthing.nix
      ../../../services/mpris-proxy.nix
    ];
  services.kbfs.enable = lib.mkForce false;
}
