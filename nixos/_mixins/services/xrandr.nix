{ ... }: {
  services.xserver = {
    videoDrivers = [ "nvidia" "intel" "amdgpu" ];

    xrandrHeads = [
      {
        output = "HDMI-1-0";
        primary = true;
        monitorConfig = ''
          Modeline "1920x1080_60.00"  339.00  3840 4080 4488 5136  2160 2163 2168 2200 -hsync +vsync
          Option "PreferredMode" "1920x1080_60.00"
          Option "Position" "0 0"
        '';
      }
      {
        output = "eDP-1";
        monitorConfig = ''
          Option "PreferredMode" "1920x1980"
          Option "Position" "0 0"
        '';
      }
    ];

    resolutions = [
      {
        x = 2048;
        y = 1152;
      }
      # mcbair
      {
        x = 1336;
        y = 768;
      }
      # oldmac
      {
        x = 1920;
        y = 1200;
      }
      # nitro
      {
        x = 1920;
        y = 1080;
      }
      {
        x = 2560;
        y = 1440;
      }
      {
        x = 3072;
        y = 1728;
      }
      {
        x = 3840;
        y = 2160;
      }
    ];
  };
}
