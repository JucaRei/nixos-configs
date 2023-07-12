{ ... }: {

  boot = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      #efiInstallAsRemovable = true;
      configurationLimit = 4;
      forceInstall = true;
      #splashMode = "stretch";
      #theme = "";

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
  };
}

