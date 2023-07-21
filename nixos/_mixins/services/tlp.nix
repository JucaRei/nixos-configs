{ pkgs, config, lib, ... }: {
  # services = {
  #   tlp = {
  #     enable = true;
  #     settings = {
  #       CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
  #       CPU_SCALING_GOVERNOR_ON_BAT = "conservative";
  #
  #       PLATFORM_PROFILE_ON_AC = "performance";
  #       PLATFORM_PROFILE_ON_BAT = "low-power";
  #
  #       DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = ["bluetooth" "wifi"];
  #       DEVICES_TO_ENABLE_ON_AC = ["bluetooth" "wifi"];
  #
  #       DISK_IOSCHED = ["none"];
  #
  #       #START_CHARGE_THRESH_BAT0 = 70;
  #       #STOP_CHARGE_THRESH_BAT0 = 80;
  #     };
  #   };
  #   udev.extraRules = ''
  #     ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
  #     ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
  #     ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
  #     ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
  #     # this leads to non-responsive input devices
  #     ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  #   '';
  #   i2p.enable = pkgs.lib.mkForce false;
  #   tor.enable = pkgs.lib.mkForce false;
  # };

  # boot = {
  #kernelParams = ["pcie_aspm.policy=powersave"];
  #extraModprobeConfig = ''
  #  options snd_hda_intel power_save=1
  #  options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
  #  options iwldvm force_cam=0
  #  options i915 enable_guc=2 enable_fbc=1 enable_psr=1 enable_rc6=1 fastboot=1
  #'';
  #kernel.sysctl = {
  #  "kernel.nmi_watchdog" = 0;
  #  "vm.dirty_writeback_centisecs" = 6000;
  #  "vm.laptop_mode" = 5;
  #};
  #};

  #environment.systemPackages = [config.boot.kernelPackages.x86_energy_perf_policy];

  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp = {
    enable = true;
    settings = {
      AHCI_RUNTIME_PM_ON_AC = "auto";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 100;
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      NMI_WATCHDOG = 0;
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersupersave";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Runtime PM causes system lockup with i350-T4
      #RUNTIME_PM_DRIVER_DENYLIST = "igb";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      SCHED_POWERSAVE_ON_AC = 0;
      SCHED_POWERSAVE_ON_BAT = 1;
      TLP_DEFAULT_MODE = "AC";
    };
  };
}
