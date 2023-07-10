{ ... }: {
  ### Some optimizations services

  services = {
    # Virtual Filesystem Support Library
    gvfs = { enable = true; };
  };

  # Fix clock issue with Windows dual boot
  time.hardwareClockInLocalTime = true;

}
