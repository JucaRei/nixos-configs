{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Bluetooth
  hardware = {

    # smooth backlight control
    #brillo.enable = true;

    #security.tpm2 = {
    #  enable = true;
    #  abrmd.enable = true;
    #};

    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      settings = { 
        General = { 
          Enable = "Source,Sink,Media,Socket"; 
          }; 
        };

      # battery info support
      #package = pkgs.bluez5-experimental;
      #settings = {
      #  # make Xbox Series X controller work
      #  General = {
      #    Class = "0x000100";
      #    ControllerMode = "bredr";
      #    FastConnectable = true;
      #    JustWorksRepairing = "always";
      #    Privacy = "device";
      #    Experimental = true;
      #  };
      #};
    };
  };
}
