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
  networking.firewall.allowedUDPPorts = [tunnel.port.int];
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.tunnel = {
    generatePrivateKeyFile = true;
    listenPort = tunnel.port.int;
    privateKeyFile = "/xxxxxxx/xxxxxxx.xxxxxxx";
    allowedIPsAsRoutes = false;
    ips = [
      "${tunnel.ip}/32"
      "${tunnel.internal.ip}/32"
    ];
    peers = [
      {
        allowedIPs = ["0.0.0.0/0"];
        endpoint = "${tunnel.external.endpoint}:${tunnel.port.str}";
        publicKey = tunnel.external.pubkey;
        persistentKeepalive = 5;
      }
    ];
    postSetup = ''
      ip route add ${tunnel.external.ip} dev tunnel scope link
      ip route add default via ${tunnel.external.ip} table 200
      ip rule add from ${tunnel.ip} lookup 200
    '';
    postShutdown = ''
      ip rule del from ${tunnel.ip} lookup 200
      ip route del default via ${tunnel.external.ip} table 200
      ip route del ${tunnel.external.ip} dev tunnel scope link
    '';
  };
}
