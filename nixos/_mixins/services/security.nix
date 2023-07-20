{username, ...}: {
  security = {
    sudo = {
      enable = true;
      # Stops sudo from timing out.
      extraConfig = ''
        ${username} ALL=(ALL) NOPASSWD:ALL
        Defaults env_reset,timestamp_timeout=-1
      '';
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };

    doas = {
      enable = false;
      extraConfig = ''
        permit nopass :wheel
      '';
    };

    rtkit.enable = true;
    polkit.enable = true;
    # tpm2.enable = true;
    # unprivilegedUsernsClone = true;

    apparmor = {
      enable = false;
      enableCache = false;
    };
  };
  #services.dbus.apparmor = "enabled";
}
