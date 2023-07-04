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
      open = true;
      modesetting.enable = true;
      prime = {
        offload.enable = false;
        sync.enable = true;

        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:0:2:0";

        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:1:0:0";

      };
      nvidiaSettings = false;
    };
  };

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

  services = {
    ### Disable suspend on lid close ###
    #upower.ignoreLid = true;
    #logind.lidSwitch = "ignore";
    #logind.lidSwitchDocked = "ignore";

    hardware.openrgb = {
      enable = true;
      motherboard = "intel";
      package = pkgs.openrgb-with-all-plugins;
    };
    xserver.videoDrivers = [ "nvidia" ];
    # Temperature management daemon
    thermald = { enable = true; };
  };

  networking.hostName = "nixtro";

  #time = {
  #  # For Windows interop
  #  hardwareClockInLocalTime = true;
  #  timeZone = "America/Sao_Paulo";
  #};

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  #powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
