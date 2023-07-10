{ lib, ... }: {
  #console.keyMap = "us";
  #console.keyMap = "br-abnt2";
  #console.keyMap = "mac-us";
  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      #LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "pt_BR.utf8";
      LC_IDENTIFICATION = "pt_BR.utf8";
      LC_MEASUREMENT = "pt_BR.utf8";
      LC_MONETARY = "pt_BR.utf8";
      LC_NAME = "pt_BR.utf8";
      LC_NUMERIC = "pt_BR.utf8";
      LC_PAPER = "pt_BR.utf8";
      LC_TELEPHONE = "pt_BR.utf8";
      LC_TIME = "pt_BR.utf8";
      #LC_COLLATE = "pt_BR.utf8";
      #LC_MESSAGES = "pt_BR.utf8";
    };
  };
  services = {
    # grep "^! " /usr/share/X11/xkb/rules/xorg.lst
    # awk '/\!\ layout/{flag=1;next}/\!\ variant/{flag=0}flag' /usr/share/X11/xkb/rules/xorg.lst | grep Portuguese
    xserver = if (builtins.isString == "nitro") then
      true {
        layout = "br,gb,us";
        xkbVariant = "pc105";
        xkbModel = "pc105";
        xkbOptions = "grp:alt_shift_toggle";
      }
    else {
      layout = "us";
      xkbVariant = "mac";
      xkbModel = "pc105";
      xkbOptions = ''
        "altwin:ctrl_win"
        "altwin:ctrl_alt_win"
        "caps:super" 
        "terminate:ctrl_alt_bksp" 
      '';
      #"caps:ctrl_modifier"
      #"lv3:alt_switch"
      #"lv3:switch,compose:lwin”
    };
    kmscon.extraOptions = "--xkb-layout=us";
  };
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  #location = {
  #  latitude = -23.539380;
  #  longitude = -46.652530;
  #};
}
