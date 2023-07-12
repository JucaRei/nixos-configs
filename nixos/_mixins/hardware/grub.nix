{ ... }: {

  boot.tmp = {
    useTmpfs = true;
    cleanOnBoot = true;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    #efiSupport = true;
    #efiInstallAsRemovable = true;
    configurationLimit = 4;
    forceInstall = true;
    #splashMode = "stretch";
    #theme = with pkgs; [ nixos-grub2-theme libsForQt5.breeze-grub ];

    ### For encrypted boot
    # enableCryptodisk = true;

    ## If tpm is activated
    # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
    # trustedBoot.enable = true;

    ## If using zfs filesystem
    # zfsSupport = true;                        # enable zfs
    # copyKernels = true; 

    #useOSProber = false;
    fsIdentifier = "label";
    gfxmodeEfi = "auto";
    #gfxmodeEfi = "1366x788";
    fontSize = 20;
    configurationName = "Nixos Configuration";
    extraEntries = ''
      menuentry "Reboot" {
        reboot
      }
      menuentry "Poweroff" {
        halt
      }
    '';
  };
}


boot = {

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
      "fs.inotify.max_user_watches = 524288"
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

  efi = {
        #canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };