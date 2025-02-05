# Screen color temperature changer
#
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.xsession.enable {
    # Only evaluate code if using X11
    services = {
      redshift = {
        enable = true;
        temperature.night = 3000;
        latitude = -23.53938;
        longitude = -46.65253;
      };
    };
  };
}
