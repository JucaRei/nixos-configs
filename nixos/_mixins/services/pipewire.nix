{ lib, ... }: {
  hardware = {
    pulseaudio = {
      enable = lib.mkForce false;
      extraConfig = "\n    load-module module-switch-on-connect\n  ";
    };
  };
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
