_: {
  boot = {
    #tmp = {
    #useTmpfs = true;
    #cleanOnBoot = true;
    #};
    loader = {
      efi = {
        #canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        device = "nodev"; # "nodev" for efi only
        efiSupport = true;
        efiInstallAsRemovable = false;
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

        useOSProber = false;
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
    };
  };
}
