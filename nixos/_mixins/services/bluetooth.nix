{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      # battery info support
      #package = pkgs.bluez5-experimental;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          # make Xbox Series X controller work
          #Class = "0x000100";
          #ControllerMode = "bredr";
          #FastConnectable = true;
          #JustWorksRepairing = "always";
          #Privacy = "device";
          #Experimental = true;
        };
      };
    };
  };
}
