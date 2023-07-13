{ desktop, pkgs, lib, ... }: {
  imports = [
    ../services/cups.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
  ] ++ lib.optional (builtins.pathExists (./. + /${desktop}.nix)) ./${desktop}.nix;

  programs.dconf.enable = true;

  # Disable xterm
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
  };
}
