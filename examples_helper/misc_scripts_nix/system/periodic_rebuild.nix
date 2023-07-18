{ lib, ... }: {
  systemd = {
    services.nixos-update-prebuild = {
      serviceConfig.Type = "oneshot";
      environment.PATH = lib.mkForce "/run/current-system/sw/bin";
      script = ''
        source /etc/profile
        mkdir -p /var/lib/nixos-update-prebuild
        cd /var/lib/nixos-update-prebuild
        nixos-rebuild --upgrade dry-activate
      '';
      # todo: send notification when update would change something
    };
    timers.nixos-update-prebuild = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nixos-update-prebuild.service" ];
      timerConfig = {
        OnCalendar = "hourly";
        Unit = "nixos-update-prebuild.service";
      };
    };
  };
}
