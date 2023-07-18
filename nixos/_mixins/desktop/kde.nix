{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs.libsForQt5; [ packagekit-qt bismuth ];
  };

  services = {
    xserver = {
      enable = true;

      modules = [ pkgs.xf86_input_wacon ];
      wacom.enable = true;
      libinput = {
        enable = true;
        touchpad.tapping = true;
        disableWhileTyping = true;
      };

      desktopManager.plasma5 = {
        enable = true;
        runUsingSystemd = true;
        excludePackages = with pkgs.libsForQt5; [
          elisa
          khelpcenter
          konsole
          oxygen
        ];
      };

      displayManager = {
        defaultSession = "plasmawayland";
        sddm.enable = true;
      };
    };
  };
}
