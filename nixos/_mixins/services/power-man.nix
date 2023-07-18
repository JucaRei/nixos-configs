{
  lib,
  desktop,
  ...
}: {
  imports =
    []
    ++ lib.optional (builtins.isString desktop == "nitro") ./_mixins/desktop;

  services = {
    power-profiles-daemon.enable = true;

    # Automatic CPU speed and power optimizer for Linux
    auto-cpufreq = {enable = true;};

    # Provide Power Management Support
    upower = {
      enable = true;
      usePercentageForPolicy = true;
      percentageLow = 40;
      percentageCritical = 20;
      percentageAction = 5;
      #criticalPowerAction = "Hibernate";
      criticalPowerAction = "HybridSleep";
    };
  };
  powerManagement.powertop.enable = true;
  # FIXME always coredumps on boot
  systemd.services.powertop.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "2s";
  };
}
