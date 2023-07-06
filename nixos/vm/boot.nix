{ lib, pkgs, ... }: {

  ####################
  ### Boot options ###
  ####################

  boot = {
    isContainer = false;

    kernelParams = [ "resume_offset=140544" ];
    resumeDevice = "/dev/disk/by-label/NIXOS";

    #cleanTmpDir = true;
    #tmpOnTmpfs = lib.mkDefault true;
    tmp = {
      useTmpfs = lib.mkDefault true;
      cleanOnBoot = true;
    };

    #blacklistedKernelModules = lib.mkDefault [ "nouveau" ];

    ### additional packages supplying kernel modules ###
    #extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback nvidia_x11 ];  

    ### additional configuration to be appended to the generated modprobe.conf ###
    #extraModprobeConfig = lib.mkDefault ''
    #  options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1
    #'';

    ##############
    ### INITRD ###
    ##############

    initrd = {
      ###  kernel modules in the initial ramdisk used during the boot process ###
      availableKernelModules = [
        "ata_piix"
        "ahci"
        "xhci_pci"
        "ehci_pci"
        "ohci_pci"
        "virtio_pci"
        "usbhid"
        "sd_mod"
        "sr_mod"
        "virtio_blk"
      ];

      ### kernel modules to be loaded in the second stage, that are needed to mount the root file system ###
      kernelModules = [
        #"z3fold"
        "crc32c-intel"
        #"lz4hc"
        #"lz4hc_compress"
        #"kvm-intel"
        #"vhost_vsock"
      ];
      checkJournalingFS = false; # for vm

      ##########################
      ### Enabled filesystem ###
      ##########################
      # supportedFilesystems = [ "vfat" "zfs" ];
      supportedFilesystems = [ "vfat" "btrfs" ]; # fat 32 and btrfs
      compressor = "zstd";
      # compressorArgs = ["-19" "-T0"];
      verbose = false;
    };

    ##############
    ### Nvidia ###
    ##############

    # extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

    #######################
    ### KERNEL Versions ###
    #######################

    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_lqx; # Liquorix kernel
    # kernelPackages = pkgs.linuxPackages_5_4;
    # kernelPackages = pkgs.linuxPackages_xanmod_stable;        # Xanmod kernel
    kernelPackages = pkgs.linuxPackages_zen;

    # Allow compilation of packages ARM/ARM64 architectures via QEMU
    # e.g. nix-build -A <pkg> --argstr system aarch64-linux
    # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
    binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
    # Temporary workaround until mwprocapture 4328 patch is merged
    # - https://github.com/NixOS/nixpkgs/pull/221209
    # kernelPackages = pkgs.linuxPackages_5_15;

    ###################################
    ### Boot Systemd or grub params ###
    ###################################

    ### Already set on desktop.nix
    #kernelParams = [];
    #consoleLogLevel = 3;

    ###################
    ### Sysctl.conf ###
    ###################
    kernel.sysctl = {
      #"kernel.sysrq" = 1;
      #"kernel.printk" = "3 3 3 3";
      "vm.vfs_cache_pressure" = 300;
      "vm.swappiness" = 25;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
      "dev.i915.perf_stream_paranoid" = 0;
      ### Improve networking
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";

      # Bypass hotspot restrictions for certain ISPs
      "net.ipv4.ip_default_ttl" = 65;
    };

    #######################
    ### Enable plymouth ###
    #######################

    #plymouth = {
    #  theme = "breeze";
    #  enable = true;
    #};

    loader = {
      ######################
      # IF using UEFI boot #
      ######################
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 5;

      #######################################
      #####  Systemd boot as bootloader #####
      #######################################
      #systemd-boot = {
      #  configurationLimit = 5;
      #  enable = true;
      #  memtest86.enable = true;
      #};

      ##########################
      ###### GRUB CONFIG #######
      ##########################
      grub = {
        #######################
        ### For legacy boot ###
        #######################

        #   enable = true;
        #   version = 2;
        #   device = "/dev/sda";                    # Name of hard drive (can also be vda)
        #   gfxmodeBios = "1920x1200,auto";
        #   gfxmodeEfi = "1920x1200,auto";
        #   zfsSupport = true                       # enable for zfs
        # };
        # timeout = 5;                              # Grub auto select timeout

        #####################
        ### FOR UEFI BOOT ###
        #####################

        enable = true;
        #version = 2;
        # default = 0;                              # "saved";
        # devices = [ "nodev" ];                    # device = "/dev/sda"; or "nodev" for efi only
        device = "nodev"; # uefi
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 5; # do not store more than 5 gen backups
        forceInstall = true; # force installation
        # splashMode = "stretch";
        # theme = "";                               # set theme

        ## For encrypted boot
        # enableCryptodisk = true;  #

        ## If tpm is activated
        # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
        # trustedBoot.enable = true;

        ## If using zfs filesystem
        # zfsSupport = true;                        # enable zfs
        # copyKernels = true;                       # https://nixos.wiki/wiki/NixOS_on_ZFS

        useOSProber = false; # check for other systems
        fsIdentifier = "label"; # mount devices config using label
        gfxmodeEfi = "1280x720,auto";
        fontSize = 20;

        configurationName = "NixOS VM test";

        ## Add more entries for grub
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
  };
}
