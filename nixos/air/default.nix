{ lib, inputs, config, pkgs, ... }: {
  imports = [
    #inputs.nixos-hardware.nixosModules.common-cpu-intel-sandy-bridge
    #inputs.nixos-hardware.nixosModules.apple-macbook-air-4
    #inputs.nixos-hardware.nixosModules.common-pc-ssd
    #../_mixins/hardware/systemd-boot.nix
    #../_mixins/hardware/refind.nix
    #../_mixins/services/dynamic-timezone.nix
    ../_mixins/services/power-man.nix
    ../_mixins/services/tlp.nix
    ../_mixins/services/networkmanager.nix
    ../_mixins/hardware/backlight.nix
    ../_mixins/virt/docker.nix
    ../_mixins/hardware/grub-efi.nix
    ../_mixins/hardware/intel-gpu-air.nix
    #../_mixins/services/tailscale.nix
    #../_mixins/services/zerotier.nix
  ];

  ############
  ### BOOT ###
  ############

  boot = {
    #isContainer = false;

    #plymouth = {
    #  enable = lib.mkForce true;
    #  theme = "breeze";
    #};

    loader = {
      efi = { canTouchEfiVariables = true; };
      grub = {
        #gfxmodeEfi = lib.mkForce "1366x788";
        efiInstallAsRemovable = lib.mkForce false;
      };
    };
    #blacklistedKernelModules = lib.mkForce [ "nvidia" ];
    extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
    extraModprobeConfig = ''
      options i915 enable_guc=2 enable_dc=4 enable_hangcheck=0 error_capture=0 enable_dp_mst=0 fastboot=1 #parameters may differ
    '';

    initrd = {
      #systemd.enable = true; # This is needed to show the plymouth login screen to unlock luks
      availableKernelModules =
        [ "uhci_hcd" "ehci_pci" "ahci" "usbhid" "sd_mod" ];
      verbose = false;
      compressor = "zstd";
      supportedFilesystems = [ "vfat" "btrfs" "ntfs" ];
    };

    kernelModules = [
      #"i965"
      "i915"
      "kvm-intel"
      "wl"
      "z3fold"
      #"hdapsd"
      "crc32c-intel"
      "lz4hc"
      "lz4hc_compress"
    ];
    kernelParams = [
      "hid_apple.swap_opt_cmd=1" # This will switch the left Alt and Cmd key as well as the right Alt/AltGr and Cmd key.
      "i915.force_probe=0116" # Force enable my intel graphics
      #"video=efifb:off" # Disable efifb driver, which crashes Xavier AGX/NX
      #"video=efifb"
      "zswap.enabled=1"
      "zswap.compressor=lz4hc"
      "zswap.max_pool_percent=20"
      "zswap.zpool=z3fold"
      "fs.inotify.max_user_watches=524288"
      "mitigations=off"
    ];
    kernel.sysctl = {
      #"kernel.sysrq" = 1;
      #"kernel.printk" = "3 3 3 3";
      "vm.vfs_cache_pressure" = 400;
      "vm.swappiness" = 20;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    #kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = [ "btrfs" ]; # fat 32 and btrfs
  };

  #environment.systemPackages = { variables = { LIBVA_DRIVER_NAME = "i965"; }; };

  ###################
  ### Hard drives ###
  ###################

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@"
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
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@home"
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
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@snapshots"
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
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@tmp"
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
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
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

  #fileSystems."/swap" = {
  #  device = "/dev/disk/by-partlabel/NIXOS";
  #  fsType = "btrfs";
  #  options = [
  #    "subvol=@swap"
  #    #"compress=lz4"
  #    "defaults"
  #    "noatime"
  #  ]; # Note these options effect the entire BTRFS filesystem and not just this volume, with the exception of `"subvol=swap"`, the other options are repeated in my other `fileSystem` mounts
  #};

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-partlabel/EFI";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nodiratime" ];
    noCheck = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-partlabel/SWAP";
    ### SWAPFILE
    #device = "/swap/swapfile";
    #size = 2 GiB;
    #device = "/swap/swapfile";
    #size = (1024 * 2); # RAM size
    #size = (1024 * 16) + (1024 * 2); # RAM size + 2 GB
  }];

  services = {
    #############
    ### Btrfs ###
    #############

    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };

    ################################
    ### Device specific services ###
    ################################
    mbpfan = {
      enable = true;
      aggressive = true;
    };

    # ddccontrol.enable = true;

    #dbus.implementation = lib.mkForce "dbus";

    # Virtual Filesystem Support Library
    #gvfs = { enable = true; };

    # Hard disk protection if the laptop falls:
    #hdapsd.enable = lib.mkDefault true;

    kmscon.extraOptions = lib.mkForce "--xkb-layout=us";

    #######################
    ### Xserver configs ###
    #######################

    xserver = {
      ### Keyboard ###
      xkbModel = lib.mkForce "pc104";
      xkbVariant = lib.mkForce "mac"; # altgr-intl
      xkbOptions = lib.mkForce ''
        #"altwin:ctrl_win"
        #"altwin:ctrl_alt_win"
        #"caps:super"
        #"terminate:ctrl_alt_bksp"

        #"caps:ctrl_modifier"
        #"lv3:alt_switch"
        #"lv3:switch,compose:lwin”
      '';

      # Crocus driver instead of i965.  /etc/X11/xorg.conf.d/92-intel.conf
      #deviceSection = ''
      # Section "Device"
      #       Identifier  "Intel Graphics"
      #       Driver      "intel"
      #       Option      "DRI" "crocus"
      # EndSection
      #'';

      ### Driver Intel ###
      #exportConfiguration = true;
      #config = ''
      #  Section "Device"
      #       Identifier  "Intel Graphics"
      #       Driver      "intel"
      #       Option      "DRI" "crocus"
      #  EndSection
      #'';

      ###########################
      ### Xserver Resolutions ###
      ###########################

      #resolutions = [
      #  {
      #    # Default resolution
      #    x = 1366;
      #    y = 788;
      #  }
      #  {
      #    x = 1280;
      #    y = 720;
      #  }
      #  {
      #    x = 1600;
      #    y = 900;
      #  }
      #  {
      #    x = 1920;
      #    y = 1080;
      #  }
      #  {
      #    x = 3840;
      #    y = 2160;
      #  }
      #];
    };
  };

  ### fix filesystem
  virtualisation.docker = { storageDriver = lib.mkForce "btrfs"; };

  #system = { autoUpgrade.allowReboot = true; };

  #hardware = {
  #  opengl = {
  #    driSupport = true;
  #    extraPackages = lib.mkForce [
  #      #pkgs.intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #      pkgs.vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #      pkgs.vaapiVdpau
  #      pkgs.libvdpau-va-gl
  #    ];
  #  };
  #};

  services.xserver.enable = lib.mkForce true;
  services.xserver.desktopManager.pantheon.enable = lib.mkForce true;
  services.xserver.displayManager.lightdm.greeters.pantheon.enable =
    lib.mkForce true;
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  virtualisation.docker.enableNvidia = lib.mkForce false;

  environment.systemPackages = with pkgs; [ intel-gpu-tools libva-utils ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
