{ ... }: {
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 10;
        consoleMode = "max";
        memtest86.enable = true;
      };
      timeout = 7;
    };
  };
}
