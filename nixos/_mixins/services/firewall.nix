{ lib, hostname, ... }:
let
  # Firewall configuration variable for syncthing
  syncthing = {
    hosts = [ "nitro" "oldmac" "air" "vm" "DietPi" ];
    tcpPorts = [ 22000 8384 ];
    udpPorts = [ 22000 21027 ];
  };
in
{
  networking = {
    firewall = {
      # if packets are still dropped, they will show up in dmesg
      #logReversePathDrops = true;
      enable = true;
      allowedTCPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts)
        syncthing.tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts)
        syncthing.udpPorts;
    };
  };
}
