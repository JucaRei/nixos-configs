{ config, lib, pkgs, ... }: {
  boot = {
    blacklistedKernelModules = lib.mkDefault [ ];
    consoleLogLevel = 3;
    kernelPackages = pkgs.linuxPackages_5_4;
    extraModulePackages = with config.boot.kernelPackages; [ nvidia_x11 ];
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
