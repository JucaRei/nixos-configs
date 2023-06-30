{ config, lib, ... }: {
  boot = {
    blacklistedKernelModules = lib.mkDefault [ ];
    consoleLogLevel = 3;
    extraModulePackages = with config.boot.kernelPackages; [
      linuxPackages_5_4
      linuxPackages_xanmod_latest
    ];
    extraModprobeConfig = lib.mkDefault "";
    initrd = {
      availableKernelModules = [ ];
      kernelModules = [ ];
      verbose = false;
    };

    kernelModules = [ "vhost_vsock" ];

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
