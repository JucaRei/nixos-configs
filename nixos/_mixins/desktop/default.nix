{ desktop, pkgs, username, lib, hostname, ... }: {
  imports = [
    ../services/cups.nix
    ../services/flatpak.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix"))
    ./${desktop}.nix;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = [ ] ++ lib.optionals
        (pkgs.system == "x86_64-linux" && hostname != "vm") # exclude vm
        (with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ]);
    };
  };

  programs = {
    dconf.enable = true;
    # Chromium is enabled by default with sane defaults.
    firefox = { enable = false; };
  };

  # Disable xterm
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  security.sudo = {
    enable = true;
    # Stops sudo from timing out.
    extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD:ALL
      Defaults env_reset,timestamp_timeout=-1
    '';
    execWheelOnly = true;
    # wheelNeedsPassword = false;
  };

  security.doas = {
    enable = false;
    extraConfig = ''
      permit nopass :wheel
    '';
  };
}
