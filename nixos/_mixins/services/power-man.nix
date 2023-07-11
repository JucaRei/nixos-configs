{ pkgs, desktop, ... }: {
  services = {
    power-profiles-daemon.enable = true;

    # Automatic CPU speed and power optimizer for Linux
    auto-cpufreq = { enable = true; };

    # Provide Power Management Support
    upower = {
      enable = true;
      usePercentageForPolicy = true;
      percentageLow = 40;
      percentageCritical = 20;
      percentageAction = 5;
      #criticalPowerAction = "Hibernate";
      criticalPowerAction = "Suspend";
    };

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
        CPU_SCALING_GOVERNOR_ON_BAT = "conservative";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = [ "bluetooth" "wifi" ];
        DEVICES_TO_ENABLE_ON_AC = [ "bluetooth" "wifi" ];

        DISK_IOSCHED = [ "none" ];

        #START_CHARGE_THRESH_BAT0 = 70;
        #STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
      # this leads to non-responsive input devices
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    '';
    i2p.enable = pkgs.lib.mkForce false;
    tor.enable = pkgs.lib.mkForce false;
  };
  ## Powertop
  environment.systemPackages = with pkgs; [ powertop ];

  boot = if (builtins.isString desktop == "nitro") then
    true {
      kernelParams = [ "pcie_aspm.policy=powersave" ];
      extraModprobeConfig = ''
        options snd_hda_intel power_save=1
        options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
        options iwldvm force_cam=0
        options i915 enable_guc=2 enable_fbc=1 enable_psr=1 enable_rc6=1 fastboot=1
      '';
      kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "vm.dirty_writeback_centisecs" = 6000;
        "vm.laptop_mode" = 5;
      };
    }
  else
    false;

  powerManagement.powertop.enable = true;
  # FIXME always coredumps on boot
  systemd.services.powertop.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "2s";
  };
}
