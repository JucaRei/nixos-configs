{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.sys.services;
  domain = "headscale.krutonium.ca";
  port = 8080;
in {
  config = mkIf cfg.headscale {
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        inherit port;
        serverUrl = "https://${domain}";
        dns = {baseDomain = "krutonium.ca";};
        settings = {logtail.enabled = false;};
      };

      nginx.virtualHosts.${domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
          proxyWebsockets = true;
        };
      };
    };
    environment.systemPackages = [config.services.headscale.package];
  };
}
