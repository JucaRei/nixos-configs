{pkgs, ...}: {
  console.keyMap = "uk";
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "caps:escape";
  systemd.services.caps-escape-console = {
    wantedBy = ["multi-user.target"];
    after = ["systemd-vconsole-setup.service"];
    path = [pkgs.kbd];
    script = ''
      echo 'keycode 58 = Escape' | loadkeys
    '';
  };
}
