_: {
  systemd.coredump.enable = false;

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  security.apparmor = {
    enable = true;
    enableCache = true;
  };

  services.fail2ban.enable = true;

  services.dbus.apparmor = "enabled";
}
