{...}: {
  #console.keyMap = "us";
  #console.keyMap = "br-abnt2";
  #console.keyMap = "mac-us";
  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.utf8";
      LC_IDENTIFICATION = "pt_BR.utf8";
      LC_MEASUREMENT = "pt_BR.utf8";
      LC_MONETARY = "pt_BR.utf8";
      LC_NAME = "pt_BR.utf8";
      LC_NUMERIC = "pt_BR.utf8";
      LC_PAPER = "pt_BR.utf8";
      LC_TELEPHONE = "pt_BR.utf8";
      LC_TIME = "pt_BR.utf8";
    };
  };
  #services.xserver = {
  #  layout = "br";
  #  layout = "us";
  #  xkbVariant = "pc105";
  #  xkbVariant = "mac";
  #  xkbModel = "pc105";
  #};
  time.timeZone = "America/Sao_Paulo";
  #location = {
  #  latitude = -23.539380;
  #  longitude = -46.652530;
  #};
}
