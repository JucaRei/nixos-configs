{ config, lib, ... }: {
  boot = {
    blacklistedKernelModules = [ ];
    consoleLogLevel = 3;
    extraModulePackages = with config.boot.kernelPackages;
      [ linuxPackages_zen ];
    extraModprobeConfig = lib.mkDefault "";
    initrd = {
      systemd.enable =
        true; # This is needed to show the plymouth login screen to unlock luks
      availableKernelModules = [
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "sdhci_pci"
        "uas"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
      kernelModules = [ ];
      verbose = false;
    };

    kernelModules = [ "kvm-intel" "vhost_vsock" ];
    kernelParams = [ "mitigations=off" ];
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "kernel.printk" = "3 3 3 3";
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };
}
