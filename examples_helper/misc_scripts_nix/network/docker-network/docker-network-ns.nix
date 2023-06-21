{pkgs, ...}:
# Based on https://wiki.archlinux.org/title/Nftables#Working_with_Docker
let
  dockerHostName = "dockernet";

  hostip = "${pkgs.util-linux}/bin/nsenter --target 1 --net -- ${ip}";
  ip = "${pkgs.iproute2}/bin/ip";

  dockerNsSetupScript = pkgs.writeShellScript "docker-netns-setup" ''
    set -exuo pipefail

    # clean up previous veth interface, if exists
    ${hostip} link delete ${dockerHostName} || true

    # create veth
    ${hostip} link add ${dockerHostName} type veth peer name docker0_ns
    ${hostip} link set docker0_ns netns "$BASHPID"
    ${ip} link set docker0_ns name eth0

    # bring host veth pair online
    ${hostip} addr add 10.0.0.1/24 dev ${dockerHostName}
    ${hostip} link set ${dockerHostName} up

    # bring ns veth pair online
    ${ip} addr add 10.0.0.100/24 dev eth0
    ${ip} link set eth0 up
    ${ip} route add default via 10.0.0.1 dev eth0
  '';

  dockerNsTeardownScript = pkgs.writeShellScript "docker-netns-teardown" ''
    set -exuo pipefail

    ${hostip} link delete ${dockerHostName} || true
  '';
in {
  systemd.services.docker.serviceConfig.PrivateNetwork = true;
  systemd.services.docker.serviceConfig.ExecStartPre = [
    ""
    "${dockerNsSetupScript}"
  ];
  systemd.services.docker.serviceConfig.ExecStopPost = [
    ""
    "${dockerNsTeardownScript}"
  ];
}
