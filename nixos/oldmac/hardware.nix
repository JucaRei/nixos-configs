# Virtual machine configuration
{ config, inputs, lib, pkgs, username, ... }: {
  imports = [ ../_mixins/services/pipewire.nix ];

  # TODO: Replace this with disko
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/swap";
    size = 1024;
  }];

  console = {
    earlySetup = true;
    # Pixel sizes of the font: 12, 14, 16, 18, 20, 22, 24, 28, 32
    # Followed by 'n' (normal) or 'b' (bold)
    font = "ter-powerline-v18n";
    packages = [ pkgs.terminus_font pkgs.powerline-fonts ];
  };

  environment.systemPackages = with pkgs; [ ];

  hardware = {
    # Workaround for https://github.com/NixOS/nixpkgs/issues/120602
    opengl = { setLdLibraryPath = true; };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
    };
  };

  services = {
    xserver.enable = true;
    videoDrivers = [ "nvidia" ];
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
