{ ... }: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 4;
        consoleMode = "max";
        memtest86.enable = true;
      };
    };
  };
}
