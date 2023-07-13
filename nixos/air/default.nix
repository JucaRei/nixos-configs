{ lib, inputs, config, pkgs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-sandy-bridge
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    #../_mixins/hardware/systemd-boot.nix
    #../_mixins/hardware/refind.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/services/power-man.nix
    ../_mixins/services/dynamic-timezone.nix
    ../_mixins/hardware/backlight.nix
    ../_mixins/virt/docker.nix
    ../_mixins/hardware/grub-efi.nix
    #../_mixins/services/tailscale.nix
    #../_mixins/services/zerotier.nix
  ];

  ############
  ### BOOT ###
  ############

  boot = {

    plymouth = {
      enable = lib.mkForce true;

    };

    loader = {
      efi = { canTouchEfiVariables = lib.mkForce false; };
      grub = {
        gfxmodeEfi = lib.mkForce "1366x788";
        efiInstallAsRemovable = true;
      };
    };
    blacklistedKernelModules = lib.mkForce [ "nvidia" "nouveau" ];
    extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
    extraModprobeConfig = lib.mkDefault ''
      options i915 enable_guc=2 enable_dc=4 enable_hangcheck=0 error_capture=0 enable_dp_mst=0 fastboot=1 #parameters may differ
    '';

    initrd = {
      #systemd.enable = true; # This is needed to show the plymouth login screen to unlock luks
      availableKernelModules =
        [ "uhci_hcd" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      verbose = false;
      compressor = "zstd";
      supportedFilesystems = [ "btrfs" ];
    };

    kernelModules = [
      #"i965"
      "i915"
      "kvm-intel"
      "wl"
      "z3fold"
      "hdapsd"
      "crc32c-intel"
      "lz4hc"
      "lz4hc_compress"
    ];
    kernelParams = [
      "mem_sleep_default=deep"
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
      "vm.vfs_cache_pressure" = 300;
      "vm.swappiness" = 25;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
    };
    #kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelPackages = pkgs.linuxPackages_zen;
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
      "compress-force=zstd:15"
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
      "compress-force=zstd:15"
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
      "compress-force=zstd:15"
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
      "compress-force=zstd:15"
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
      "compress-force=zstd:15"
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
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };

    mbpfan = {
      enable = true;
      aggressive = true;
    };

    # ddccontrol.enable = true;

    dbus.implementation = lib.mkForce "dbus";

    # Virtual Filesystem Support Library
    gvfs = { enable = true; };

    # Hard disk protection if the laptop falls:
    hdapsd.enable = lib.mkDefault true;

    kmscon.extraOptions = lib.mkForce "--xkb-layout=us";

    xserver = {
      #layout = lib.mkForce "us";

      

      # Crocus driver instead of i965.  /etc/X11/xorg.conf.d/92-intel.conf 
      #deviceSection = ''
      # Section "Device"
	    #       Identifier  "Intel Graphics"
	    #       Driver      "intel"
	    #       Option      "DRI" "crocus"
      # EndSection
      #'';

      exportConfiguration = true;
      config = ''
        Section "Device"
	            Identifier  "Intel Graphics"
	            Driver      "intel"
	            Option      "DRI" "crocus"
        EndSection
      '';

      videoDrivers = ["intel"];
      resolutions = [
        {
          # Default resolution
          x = 1366;
          y = 788;
        }
        {
          x = 1280;
          y = 720;
        }
        {
          x = 1600;
          y = 900;
        }
        {
          x = 1920;
          y = 1080;
        }
        {
          x = 3840;
          y = 2160;
        }
      ];
    };
  };

  ### fix filesystem
  virtualisation.docker = { storageDriver = lib.mkForce "btrfs"; };

  #system = { autoUpgrade.allowReboot = true; };

  hardware.opengl = {
    extraPackages = lib.mkForce [
      pkgs.vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
