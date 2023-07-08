{ config, lib, pkgs, ... }: {
  boot = {

    blacklistedKernelModules = [ "nvidia" "nouveau" ];
    extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
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
      verbose = false;
      compressor = "zstd";
    };

    kernelModules = [
      "i915"
      "kvm-intel"
      "wl"
      "z3fold"
      "crc32c-intel"
      "lz4hc"
      "lz4hc_compress"
    ];
    kernelParams = [
      "mitigations=off"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
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
    supportedFilesystems = [ "exfat" "ext" "vfat" "btrfs" ]; # fat 32 and btrfs

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      ### Systemd-BOOT
      #systemd-boot = {
      #  consoleMode = "max";
      #  configurationLimit = 10;
      #  enable = true;
      #  memtest86.enable = true;
      #};
      timeout = 10;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        #efiInstallAsRemovable = true;
        configurationLimit = 4;
        forceInstall = true;
        useOSProber = false;
        fsIdentifier = "label";
        gfxmodeEfi = "1366x788";
        fontSize = 20;
        configurationName = "Nixos oldMacbook Air";
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
  };
  console = {
    earlySetup = true;
    font = "ter-powerline-v18n";
    keyMap = "us";
    packages = with pkgs; [ terminus_font powerline-fonts ];
  };
}
