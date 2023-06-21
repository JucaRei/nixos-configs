{...}: let
  tunnel.port.int = xxxxxx;
  tunnel.port.str = "xxxxxx";
  tunnel.ip = "x.x.x.x";
  tunnel.external.ip = "x.x.x.x";
  tunnel.external.endpoint = "x.x.x.x";
  tunnel.external.pubkey = "xxxxxxxxxxxxxxxxxxxxx";
  tunnel.internal.ip = "x.x.x.x";
  tunnel.internal.pubkey = "xxxxxxxxxxxxxxxxxxxxx";
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  networking.firewall.allowedUDPPorts = [tunnel.port.int];
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.tunnel = {
    generatePrivateKeyFile = true;
    listenPort = tunnel.port.int;
    privateKeyFile = "/xxxxxxx/xxxxxxx.xxxxxxx";
    allowedIPsAsRoutes = false;
    ips = ["${tunnel.external.ip}/32"];
    peers = [
      {
        allowedIPs = [
          "${tunnel.ip}/32"
          "${tunnel.internal.ip}/32"
        ];
        publicKey = tunnel.internal.pubkey;
      }
    ];
    postSetup = ''
      ip route add ${tunnel.internal.ip} dev tunnel scope link
      ip route add ${tunnel.ip} via ${tunnel.internal.ip} dev tunnel onlink
      ip neighbour add proxy ${tunnel.ip} dev enp1s0
    '';
    postShutdown = ''
      ip neighbour del proxy ${tunnel.ip} dev enp1s0
      ip route del ${tunnel.ip} via ${tunnel.internal.ip} dev tunnel onlink
      ip route del ${tunnel.internal.ip} dev tunnel scope link
    '';
  };
}
