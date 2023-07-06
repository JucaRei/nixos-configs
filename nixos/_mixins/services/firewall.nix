{ lib, hostname, ... }:
let
  # Firewall configuration variable for syncthing
  syncthing = {
    hosts = [ "nitro" "oldmac" "mcbair" "vm" "DietPi" ];
    tcpPorts = [ 22000 8384 ];
    udpPorts = [ 22000 21027 ];
  };
in {
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.udpPorts;
    };
  };
}
