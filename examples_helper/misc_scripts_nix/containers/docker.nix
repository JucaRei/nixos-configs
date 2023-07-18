_: {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # services.kubernetes.roles = [ "master" "node" ];
  # virtualisation.docker.extraOptions = "--iptables=false --ip-masq=false -b cbr0";
  # networking.bridges.cbr0.interfaces = [];
  # networking.interfaces.cbr0 = {};

  # FIXME: mkIf (virtualisation.docker.storageDriver == "zfs") ...
  # systemd.services.kubelet.path = [ pkgs.zfs ];

  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "-H 0.0.0.0:2376 --tlsverify --tlscacert /run/keys/docker/ca.pem --tlscert /run/keys/docker/server-cert.pem --tlskey /run/keys/docker/server-key.pem";
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.docker.liveRestore = false; # FIXME: required for swarm :/
}
