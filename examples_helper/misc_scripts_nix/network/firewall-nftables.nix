{ config
, pkgs
, lib
, ...
}:
with lib; let
  verifiedNetfilter =
    { text
    , modules ? [ ]
    ,
    }:
    let
      file = pkgs.writeText "netfilter" text;
      vmTools = pkgs.vmTools.override {
        rootModules =
          [
            "virtio_pci"
            "virtio_mmio"
            "virtio_blk"
            "virtio_balloon"
            "virtio_rng"
            "ext4"
            "unix"
            "9p"
            "9pnet_virtio"
            "crc32c_generic"
          ]
          ++ modules;
      };

      check = vmTools.runInLinuxVM (
        pkgs.runCommand "nft-check"
          {
            buildInputs = [ pkgs.nftables ];
            inherit file;
          } ''
          set -ex
          # make sure protocols & services are known
          ln -s ${pkgs.iana-etc}/etc/protocol /etc/protocol
          ln -s ${pkgs.iana-etc}/etc/services /etc/services
          # test the configuration
          nft --file $file
          set +x
        ''
      );
    in
    "#checked with ${check}\n" + text;

  ruleset =
    let
      trustedInterfaces = builtins.concatStringsSep "\n" (
        lib.forEach cfg.trustedInterfaces (x: "iifname ${x} accept")
      );

      makePorts = ports: protocol:
        if (length ports) == 0
        then ""
        else "${protocol} dport { ${lib.concatMapStringsSep '','' toString ports} } accept";
      makePortRanges = portRanges: protocol: lib.concatMapStringsSep "\n" (pr: "${protocol} dport ${toString pr.from}-${toString pr.to} accept") portRanges;

      mkCommonRules = rules: ''
        # tcp and udp ports
        ${makePorts rules.allowedTCPPorts "tcp"}
        ${makePorts rules.allowedUDPPorts "udp"}

        # tcp and udp port ranges
        ${makePortRanges rules.allowedTCPPortRanges "tcp"}
        ${makePortRanges rules.allowedUDPPortRanges "udp"}
      '';

      allowPingIPv4Text = "icmp type echo-request accept";
      allowPingIPv6Text = ''
        icmpv6 type {
            echo-request,
            nd-router-solicit,
            nd-router-advert,
            nd-neighbor-solicit,
            nd-neighbor-advert,
        } accept
      '';

      # networking.firewall.* which is not implemented yet
      trashFile = pkgs.writeText "nftables-trashfile" ''
        extraStopCommands: ${lib.generators.toJSON {} cfg.extraStopCommands}
        extraCommands: ${lib.generators.toJSON {} cfg.extraCommands}
        checkReversePath: ${lib.generators.toJSON {} cfg.checkReversePath}

        connectionTrackingModules DEPRECATED: ${lib.generators.toJSON {} cfg.connectionTrackingModules}
      '';
    in
    ''
      # firewall rules which was defined in `networking.firewall.*`
      # but which was not handled/implemented yet
      # ${trashFile}

      table inet filter {
        chain input {
          type filter hook input priority filter; policy drop;

          # allow traffic from established and related packets
          ct state {established, related} accept

          # drop invalid packets.
          ct state invalid drop

          # allow loopback traffic
          ${trustedInterfaces}

          # allow ICMP
          ${
        if cfg.allowPing
        then allowPingIPv4Text
        else ""
      }
          ${
        if cfg.allowPing
        then allowPingIPv6Text
        else ""
      }

          # common rules
          ${mkCommonRules cfg}

          # interface rules
          ${lib.concatMapStrings (name: "iifname ${name} jump interface-${name}\n") (lib.attrNames cfg.interfaces)}
        }

        # interface chains
        ${lib.concatMapStringsSep "\n\n" (x: "chain interface-${x.name} {\n ${mkCommonRules x} \n}") (lib.mapAttrsToList (n: v: v // {name = n;}) cfg.interfaces)}
      }

      ${cfg.extraRules}
      ${lib.concatMapStringsSep "\n" (path: ''include "${path}"'') cfg.rulesets}
    '';

  # common options, needed for interfaces and the base config
  commonOptions = {
    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      apply = canonicalizePortList;
      example = [ 22 80 ];
      description = ''
        List of TCP ports on which incoming connections are
        accepted.
      '';
    };

    allowedTCPPortRanges = mkOption {
      type = types.listOf (types.attrsOf types.port);
      default = [ ];
      example = [
        {
          from = 8999;
          to = 9003;
        }
      ];
      description = ''
        A range of TCP ports on which incoming connections are
        accepted.
      '';
    };

    allowedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      apply = canonicalizePortList;
      example = [ 53 ];
      description = ''
        List of open UDP ports.
      '';
    };

    allowedUDPPortRanges = mkOption {
      type = types.listOf (types.attrsOf types.port);
      default = [ ];
      example = [
        {
          from = 60000;
          to = 61000;
        }
      ];
      description = ''
        Range of open UDP ports.
      '';
    };
  };

  # cfg = config.networking.nffirewall;
  cfg = config.networking.firewall;

  canonicalizePortList = ports: lib.unique (builtins.sort builtins.lessThan ports);
in
{
  # TODO(eyJhb): remove this at some point?
  disabledModules = [
    "services/networking/firewall.nix"
  ];

  options.networking.firewall =
    {
      enable = mkEnableOption "netfilter-firewall";

      extraRules = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra rules that will be added right before rulesets are included.

          The rules here will be validated by nft.
        '';
      };

      rulesets = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          List of files that will be included from the main nftables file.
          These will be included at the end of the main nftables file.

          The rules here will be validated by nft.
        '';
      };

      allowPing = mkOption {
        type = types.bool;
        default = true;
      };

      trustedInterfaces = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "enp0s2" ];
        description = ''
          Traffic coming in from these interfaces will be accepted
          unconditionally.  Traffic from the loopback (lo) interface
          will always be accepted.
        '';
      };

      # TODO(eyJhb): not implemented
      checkReversePath = mkOption {
        type = types.either types.bool (types.enum [ "strict" "loose" ]);
        default = false;
        apply = x: trace "nftables.firewall: checkReversePath value ${lib.generators.toJSON {} x}" x;
      };
      extraCommands = mkOption {
        type = types.lines;
        default = "";
        apply = x: trace "nftables.firewall: extraCommands value ${lib.generators.toJSON {} x}" x;
      };
      extraStopCommands = mkOption {
        type = types.lines;
        default = "";
        apply = x: trace "nftables.firewall: extraStopCommands value ${lib.generators.toJSON {} x}" x;
      };
      interfaces = mkOption {
        default = { };
        type = with types; attrsOf (submodule [{ options = commonOptions; }]);
        description = ''
          Interface-specific open ports.
        '';
      };
      # DEPRECATED! DON'T USE !!
      connectionTrackingModules = mkOption {
        type = types.listOf types.str;
        default = [ ];
        apply = x: trace "nftables.firewall DEPRECATED: connectionTrackingModules value ${lib.generators.toJSON {} x}" x;
      };
    }
    // commonOptions;

  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "lo" ];

    networking.nftables = {
      enable = true;
      ruleset = verifiedNetfilter {
        modules = [ ];
        text = ruleset;
      };
    };
  };
}
