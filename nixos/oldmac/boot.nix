{ config, lib, pkgs, ... }: {
  boot = {
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    consoleLogLevel = 3;
    extraModulePackages = with config.boot.kernelPackages; [ ];
    extraModprobeConfig = lib.mkDefault "";
    initrd = {
      availableKernelModules = [
        "ahci"
        "ehci_pci"
        "ohci_pci"
        "sr_mod"
        "usbhid"
        "virtio_blk"
        "virtio_pci"
        "xhci_pci"
      ];
      kernelModules = [ ];
      verbose = false;
    };

    kernelModules = [ "vhost_vsock" ];

    kernelPackages = with pkgs; [ linuxPackages_5_4 linuxPackages_6_3 ];

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
