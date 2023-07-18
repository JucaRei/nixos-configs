{ lib, ... }:
with lib.hm.gvariant; {
  imports = [
    #../../../services/syncthing.nix 
    ../../../services/mpris-proxy.nix
  ];
  services.kbfs.enable = lib.mkForce false;
}
