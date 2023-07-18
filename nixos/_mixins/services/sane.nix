{
  pkgs,
  lib,
  desktop,
  ...
}: {
  imports =
    []
    ++ lib.optional (builtins.isString desktop)
    ../desktop/apps/utils/simple-scan.nix;

  hardware = {
    sane = {
      enable = false;
      extraBackends = with pkgs; [
        #hplipWithPlugin
        sane-airscan
      ];
    };
  };
}
