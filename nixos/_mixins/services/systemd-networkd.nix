_: {
  networking = {
    usePredictableInterfaceNames = true;
    useNetworkd = true;

    # We're using networkd to configure so we're disabling this
    # service.
    useDHCP = false;
    dhcpcd.enable = false;
  };

  # Enable systemd-resolved. This is mostly setup by `systemd.network.enable`
  # by we're being explicit just to be safe.
  services.resolved = {
    enable = true;
    llmnr = "true";
  };

  # Combining my ethernet and wireless network interfaces.
  systemd.network = {
    #enable = false;
    netdevs."40-bond1" = {
      netdevConfig = {
        Name = "bond1";
        Kind = "bond";
      };
    };

    networks = {
      "40-bond1" = {
        matchConfig.Name = "bond1";
        networkConfig.DHCP = "yes";
      };

      "40-bond1-dev1" = {
        matchConfig.Name = "eth0";
        networkConfig.Bond = "bond1";
      };

      "40-bond1-dev2" = {
        matchConfig.Name = "wlan0";
        networkConfig = {
          Bond = "bond1";
          IgnoreCarrierLoss = "15";
        };
      };
    };
  };
  # https://github.com/numtide/srvos/blob/main/nixos/common/networking.nix
  systemd.services = {
    #systemd-networkd.stopIfChanged = false;
    #systemd-resolved.stopIfChanged = false;
  };
}
