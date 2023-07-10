{ lib, ... }:
with lib.hm.gvariant;
{
  imports = [ 
    ../../../services/mpris-proxy.nix
    #../../services/syncthing.nix
  ];
  #dconf.settings = {
  #  "org/gnome/desktop/background" = {
  #    picture-options = "zoom";
  #    picture-uri = "file:///home/juca/Pictures/Determinate/DeterminateColorway-1280x720.png";
  #  };
  #};
  services.kbfs.enable = lib.mkForce false;
}
