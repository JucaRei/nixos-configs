{ config, lib, pkgs, ... }: {
  boot = {
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    consoleLogLevel = 3;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = lib.mkDefault ''
      blacklist nouveau
      options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1

      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_nsrs=1
    ''; # Needed to run OSX-KVM
    initrd = {
      availableKernelModules =
        [ "ahci" "nvme" "uas" "usbhid" "sd_mod" "xhci_pci" ];
      kernelModules = [ "kvm-intel" "nvidia" "vhost_vsock" ];
      verbose = false;
    };

    kernelModules = [ "kvm-intel" "nvidia" "vhost_vsock" ];

    # Temporary workaround until mwprocapture 4328 patch is merged
    # - https://github.com/NixOS/nixpkgs/pull/221209
    kernelPackages = pkgs.linuxPackages_6_3;

    kernelParams = [ "mitigations=off" ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80
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
