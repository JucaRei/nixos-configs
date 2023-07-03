{ lib, ... }: {
  hardware = { pulseaudio.enable = lib.mkForce false; };
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      config.pipewire = {
        # Low-latency configuration for Pro Audio
        "context.properties" = {
          #"link.max-buffers" = 16;
          "log.level" = 2;
          "default.clock.rate" = 44100; # or you can set '48000'
          "default.clock.quantum" = 1024; # latency for recording
          #"default.clock.min-quantum" = 32;
          #"default.clock.max-quantum" = 32;
          "core.daemon" = true;
          "core.name" = "pipewire-0";
        };
        "context.modules" = [
          {
            name = "libpipewire-module-rtkit";
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
            flags = [ "ifexists" "nofail" ];
          }
          { name = "libpipewire-module-protocol-native"; }
          { name = "libpipewire-module-profiler"; }
          { name = "libpipewire-module-metadata"; }
          { name = "libpipewire-module-spa-device-factory"; }
          { name = "libpipewire-module-spa-node-factory"; }
          { name = "libpipewire-module-client-node"; }
          { name = "libpipewire-module-client-device"; }
          {
            name = "libpipewire-module-portal";
            flags = [ "ifexists" "nofail" ];
          }
          {
            name = "libpipewire-module-access";
            args = { };
          }
          { name = "libpipewire-module-adapter"; }
          { name = "libpipewire-module-link-factory"; }
          { name = "libpipewire-module-session-manager"; }
        ];

        # Pro Audio
        "context.objects" = [
          {
            # A default dummy driver. This handles nodes marked with the "node.always-driver"
            # properyty when no other driver is currently active. JACK clients need this.
            factory = "spa-node-factory";
            args = {
              "factory.name" = "support.node.driver";
              "node.name" = "Dummy-Driver";
              "priority.driver" = 8000;
            };
          }
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "Microphone-Proxy";
              "node.description" = "Microphone";
              "media.class" = "Audio/Source/Virtual";
              "audio.position" = "MONO";
            };
          }
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "Main-Output-Proxy";
              "node.description" = "Main Output";
              "media.class" = "Audio/Sink";
              "audio.position" = "FL,FR";
            };
          }
        ];
      };
      # Bluetooth Pipewire
      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
              # SBC-XQ is not expected to work on all headset + adapter combinations.
              "bluez5.sbc-xq-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            {
              "node.name" = "~bluez_input.*";
            }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
        }
      ];
      # Controlling ALSA device
      # It is possible to configure various aspects of soundcards through PipeWire
      media-session.config.alsa-monitor = {
        rules = [{
          matches = [{ "node.name" = "alsa_output.*"; }];
          actions = {
            update-props = {
              "audio.format" = "S32LE";
              "audio.rate" =
                96000; # for USB soundcards it should be twice your desired rate
              "api.alsa.period-size" =
                32; # defaults to 1024, tweak by trial-and-error
              #"api.alsa.disable-batch" = true; # generally, USB soundcards use the batch mode
            };
          };
        }];
      };
    };
  };
}
