{
  pkgs,
  lib,
  config,
  ...
}: let
  nftablesStartScript = pkgs.writeScript "nftables-rules" ''
    #!${pkgs.nftables}/bin/nft -f
    flush ruleset
    include "${config.networking.nftables.rulesetFile}"
  '';
in {
  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip nat {
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;

        tcp dport { 8080 } dnat to 10.0.0.100;
      }

      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        iifname dockernet masquerade;
      }
    }
  '';

  # XXX: default script is checking if ip_tables is loaded, and fails hard if it is.
  #      In our case, that's unwanted
  #      iptables and nftables work just fine together at least on >5.x kernels.
  systemd.services.nftables.serviceConfig.ExecStart =
    lib.mkForce nftablesStartScript;
  systemd.services.nftables.serviceConfig.ExecReload =
    lib.mkForce nftablesStartScript;
}
