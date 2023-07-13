{ config, lib, pkgs, inputs, ... }: {

  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../_mixins/services/pipewire.nix
    ../_mixins/services/power-man.nix
    ../_mixins/hardware/nvidia.nix
    ../_mixins/hardware/gfx-intel.nix
    #../_mixins/hardware/grub.nix
    #../_mixins/hardware/tpm.nix
    ../_mixins/virt
  ];
  boot = {

    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = lib.mkDefault ''
      options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1

      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_nsrs=1
    ''; # Needed to run OSX-KVM
    initrd = {
      availableKernelModules =
        [ "ahci" "nvme" "uas" "usbhid" "sd_mod" "xhci_pci" ];
      kernelModules = [ "kvm-intel" "nvidia" ];
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

  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/home";
    fsType = "xfs";
  };

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  environment.systemPackages = with pkgs;
    [
      nvtop
      #polychromatic 
    ];

  # This allows you to dynamically switch between NVIDIA<->Intel using
  # nvidia-offload script
  specialisation = {
    nvidia-offload.configuration = {
      hardware.nvidia = {
        prime = {
          offload.enable = lib.mkForce true;
          sync.enable = lib.mkForce false;
        };
        modesetting.enable = lib.mkForce false;
      };
      system.nixos.tags = [ "nvidia-offload" ];
    };
  };

  hardware = {
    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  nixpkgs = {
    config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
    
    hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
