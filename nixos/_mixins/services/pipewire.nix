{ lib, pkgs, desktop, ... }: {

  environment.systemPackages = with pkgs; [
    pulsemixer # Terminal PulseAudio mixer
  ] ++ lib.optionals (desktop != null) [
    pavucontrol # Terminal Media Controller
  ];
  hardware = {
    pulseaudio = {
      enable = lib.mkForce false;
      extraConfig = "\n    load-module module-switch-on-connect\n  ";
    };
  };

  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      #alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      #lowLatency = {
      ## enable this module      
      #enable = true;
      ## defaults (no need to be set unless modified)
      #quantum = 64;
      #rate = 48000;
    };
  };
}
