{ config, ... }:
let on = { enable = true; };
in {
  services.pipewire = on // {
    config = {
      pipewire = {
        "pulse.properties" = {
          "server.address" = [
            {
              address = "unix:/tmp/pulse"; # address
              client.access = "allowed"; # permissions for clients
            }
            {
              address = "tcp:4713"; # address
              client.access = "allowed"; # permissions for clients
            }
          ];
        };

        "context.properties" = {
          "log.level" = 3; # https://docs.pipewire.org/page_daemon.html
        };
        "context.modules" = [
          {
            args = { "nice.level" = -11; };
            flags = [ "ifexists" "nofail" ];
            name = "libpipewire-module-rt";
          }
          { name = "libpipewire-module-protocol-native"; }
          { name = "libpipewire-module-profiler"; }
          { name = "libpipewire-module-metadata"; }
          { name = "libpipewire-module-spa-device-factory"; }
          { name = "libpipewire-module-spa-node-factory"; }
          { name = "libpipewire-module-client-node"; }
          { name = "libpipewire-module-client-device"; }
          {
            flags = [ "ifexists" "nofail" ];
            name = "libpipewire-module-portal";
          }
          {
            args = { };
            name = "libpipewire-module-access";
          }
          { name = "libpipewire-module-adapter"; }
          { name = "libpipewire-module-link-factory"; }
          { name = "libpipewire-module-session-manager"; }
          {
            name = "libpipewire-module-protocol-pulse";
            args = { };
          }
        ];
      };
    };
    audio = on;
    jack = on;
    alsa = on;
    systemWide = true;
    socketActivation = false;
  };
}
