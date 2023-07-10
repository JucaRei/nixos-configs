{ config, lib, pkgs, ... }: {
  imports = [
    #../_mixins/hardware/systemd-boot.nix
    ../_mixins/hardware/grub.nix
  ];
  boot = {

    plymouth = {
      enable = true;
    };

    blacklistedKernelModules = [ "nvidia" "nouveau" ];
    extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
    extraModprobeConfig = lib.mkDefault "";

    initrd = {
      systemd.enable =
        true; # This is needed to show the plymouth login screen to unlock luks
      availableKernelModules =
        [ "uhci_hcd" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      verbose = false;
      compressor = "zstd";
    };

    kernelModules = [
      "i965"
      #"i915"
      "kvm-intel"
      "vhost_vsock"
      "wl"
      "z3fold"
      "crc32c-intel"
      "lz4hc"
      "lz4hc_compress"
    ];
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=lz4hc"
      "zswap.max_pool_percent=20"
      "zswap.zpool=z3fold"
      "mem_sleep_default=deep"
    ];
    kernel.sysctl = {
      #"kernel.sysrq" = 1;
      #"kernel.printk" = "3 3 3 3";
      "vm.vfs_cache_pressure" = 300;
      "vm.swappiness" = 25;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    supportedFilesystems = [ "exfat" "ext" "vfat" "btrfs" ]; # fat 32 and btrfs
  };
  console = {
    earlySetup = true;
    font = "ter-powerline-v18n";
    keyMap = "us";
    packages = with pkgs; [ terminus_font powerline-fonts ];
  };
}
