# ## Returns dnsname-cni to nixpkgs' podman
{ pkgs, ... }: {
  environment.etc."cni/net.d/87-podman-bridge.conflist".source =
    let
      cfgExtraPlugins = [{
        type = "dnsname";
        domainName = "dns.podman";
        capabilities.aliases = true;
      }];
      cfgPackage = pkgs.podman;
    in
    pkgs.runCommand "87-podman-bridge.conflist"
      {
        nativeBuildInputs = [ pkgs.jq ];
        extraPlugins = builtins.toJSON cfgExtraPlugins;
        jqScript = ''
          . + { "plugins": (.plugins + $extraPlugins) }
        '';
      } ''
      jq <${cfgPackage.src}/cni/87-podman-bridge.conflist \
        --argjson extraPlugins "$extraPlugins" \
        "$jqScript" \
        >$out
    '';

  virtualisation.containers.containersConf.cniPlugins = [ pkgs.dnsname-cni ];
}
