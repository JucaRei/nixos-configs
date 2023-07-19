_: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = ["sap"];
    hsphfpd.enable = true;
    settings = {
      General = {
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
    };
  };
}
