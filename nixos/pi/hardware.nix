{ inputs, lib, pkgs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z13
    ../_mixins/services/pipewire.nix
  ];

  # TODO: Replace this with disko
  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  console = {
    earlySetup = true;
    # Pixel sizes of the font: 12, 14, 16, 18, 20, 22, 24, 28, 32
    # Followed by 'n' (normal) or 'b' (bold)
    font = "ter-powerline-v28n";
    packages = [ pkgs.terminus_font pkgs.powerline-fonts ];
  };

  environment.systemPackages = with pkgs;
    [
      #nvtop-amd
    ];

  hardware = {
    bluetooth.enable = true;
    bluetooth.settings = {
      General = { Enable = "Source,Sink,Media,Socket"; };
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = false;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
