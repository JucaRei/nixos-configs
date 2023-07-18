{lib, ...}:
with lib.hm.gvariant; {
  imports = [
    ../../../apps/vorta.nix
    ../../../services/keybase.nix
    ../../../services/maestral.nix
    ../../../services/mpris-proxy.nix
    ../../../apps/sakura.nix
    #../../services/syncthing.nix
  ];
  services.kbfs.enable = lib.mkForce false;
}
