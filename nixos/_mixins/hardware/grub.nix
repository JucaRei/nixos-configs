{ config, lib, pkgs, ... }: {
  boot = {
    tmp = {
	useTmpfs = lib.mkDefault true;
	cleanOnBoot = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        #efiInstallAsRemovable = true;
        configurationLimit = 4;
        forceInstall = true;
        #useOSProber = false;
        fsIdentifier = "label";
        gfxmodeEfi = "1366x788";
        fontSize = 20;
        configurationName = "Nixos oldMacbook Air";
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
