{ config, inputs, lib, pkgs, username, ... }: {
  imports = [
    #inputs.nixos-hardware.nixosModules.common-pc
    ../_mixins/services/pipewire.nix
  ];

  # TODO: Replace this with disko
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:5"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:5"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:5"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/var/tmp" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:5"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:5"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nodiratime" ];
    noCheck = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-label/SWAP";
    #size = 2 GiB;
  }];

  ############
  ### Zram ###
  ############

  #zramSwap = {
  #  enable = true;
  #  swapDevices = 3;
  #  memoryPercent = 20; # 20% of total memory
  #  algorithm = "zstd";
  #};

  hardware = {
    bluetooth.enable = true;
    bluetooth.settings = {
      General = { Enable = "Source,Sink,Media,Socket"; };
    };
  };

  #mwProCapture.enable = true;

  ##############
  ### Nvidia ###
  ##############

  #nvidia = {
  #  prime = {
  #    #amdgpuBusId = "PCI:3:0:0";
  #    #nvidiaBusId = "PCI:4:0:0";
  #    sync.enable = true; # Enable NVIDIA Optimus support using the NVIDIA proprietary driver via PRIME. GPU will be always on and used for all rendering
  # Make the Radeon RX6800 default. The NVIDIA T600 is on for CUDA/NVENC
  #    reverseSync.enable = true;
  #    offload = {
  #      ## Enable render offload support using the NVIDIA proprietary driver via PRIME.
  #      enableOffloadCmd = true; ## Adds a nvidia-offload convenience script to environment.systemPackages for offloading programs to an nvidia device
  #      enable = true;
  #    };
  #  };
  #  powerManagement = {
  #    enable = true;
  #    finegrained = true;
  #  };
  #  modesetting.enable = true; # Enabling this fixes screen tearing when using Optimus via PRIME
  #  package = config.boot.kernelPackages.nvidiaPackages.stable; # nvidiaPackages.legacy_340
  #  nvidiaSettings = false;
  #};

  ######################
  ### OpenGL drivers ###
  ######################

  # opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   extraPackages = with pkgs; [intel-media-driver intel-ocl vaapiIntel];
  # };
  #openrazer = {
  #  enable = true;
  #  devicesOffOnScreensaver = false;
  #  keyStatistics = true;
  #  mouseBatteryNotifier = true;
  #  syncEffectsEnabled = true;
  #  users = ["${username}"];
  #};
  #xone.enable = true;
  # };

  ###############################
  ### High-resolution display ###
  ###############################
  #video.hidpi.enable = lib.mkDefault true;

  ###########
  ### CPU ###
  ###########
  #cpu = {
  #  intel = {
  #    updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #    # updateMicrocode = true;
  #  };
  #};
  # virtualisation.virtualbox.guest.enable = true;     #currently disabled because package is broken

  services = {
    #hardware.openrgb = {
    #  enable = true;
    #  motherboard = "intel";
    #  package = pkgs.openrgb-with-all-plugins;
    #};
    #############
    ### BTRFS ###
    #############
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
    #logind.lidSwitch = "suspend";
    #thermald.enable = true;
    #upower.enable = true;
    kmscon.extraOptions = lib.mkForce "--xkb-layout=br";
    xserver = {
      resolutions = [
        {
          x = 1920;
          y = 1080;
        }
        {
          x = 1280;
          y = 720;
        }
        # { x = 1600; y = 900; }
        # { x = 3840; y = 2160; }
      ];
      #videoDrivers = [
      #  "amdgpu"
      #  "nvidia"
      #];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
