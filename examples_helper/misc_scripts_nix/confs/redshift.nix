#
#  Screen color temperature changer
#
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.xsession.enable) {
    # Only evaluate code if using X11
    services = {
      redshift = {
        enable = true;
        temperature.night = 3000;
        latitude = -23.539380;
        longitude = -46.652530;
      };
    };
  };
}
