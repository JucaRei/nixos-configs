{ config, lib, pkgs, ... }: {
  boot = {

    blacklistedKernelModules = [ "nvidia" "nouveau" ];
    extraModulePackages = with config.boot.kernelPackages; [ ];
    extraModprobeConfig = lib.mkDefault "";

    tmp = {
      useTmpfs = lib.mkDefault true;
      cleanOnBoot = true;
    };

    initrd = {
      systemd.enable =
        true; # This is needed to show the plymouth login screen to unlock luks
      availableKernelModules =
        [ "uhci_hcd" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      verbose = false;
    };

    kernelModules =
      [ "kvm-intel" "wl" "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" ];
    kernelParams = [ "mitigations=off" ];
    kernel.sysctl = {
      #"kernel.sysrq" = 1;
      #"kernel.printk" = "3 3 3 3";
      "vm.vfs_cache_pressure" = 300;
      "vm.swappiness" = 25;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
      "dev.i915.perf_stream_paranoid" = 0;
      ### Improve networking
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";

      # Bypass hotspot restrictions for certain ISPs
      "net.ipv4.ip_default_ttl" = 65;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    supportedFilesystems = [ "apfs" "exfat" "vfat" "btrfs" ]; # fat 32 and btrfs

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };
}
