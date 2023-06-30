{ inputs, lib, pkgs, username, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    #inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../_mixins/services/pipewire.nix
  ];

  console = {
    earlySetup = true;
    # Pixel sizes of the font: 12, 14, 16, 18, 20, 22, 24, 28, 32
    # Followed by 'n' (normal) or 'b' (bold)
    font = "ter-powerline-v28n";
    packages = [ pkgs.terminus_font pkgs.powerline-fonts ];
  };

  # TODO: Replace this with disko
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

  environment.systemPackages = with pkgs; [ nvtop polychromatic ];

  hardware = {
    bluetooth.enable = true;
    bluetooth.settings = {
      General = { Enable = "Source,Sink,Media,Socket"; };
    };
    # mwProCapture.enable = true;
    nvidia = {
      prime = {
        #amdgpuBusId = "PCI:3:0:0";
        nvidiaBusId = "PCI:1:0:0";
        # Make the Radeon RX6800 default. The NVIDIA T600 is on for CUDA/NVENC
        #reverseSync.enable = true;
      };
      nvidiaSettings = false;
    };
  };

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "intel";
      package = pkgs.openrgb-with-all-plugins;
    };
    xserver.videoDrivers = [ "nvidia" ];
    # Temperature management daemon
    thermald = { enable = true; };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
