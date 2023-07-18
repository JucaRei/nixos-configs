{hyprland, ...}: {
  imports = [
    hyprland.nixosModules.default{
      programs.hyprland = {
        enable = true;
        nvidiaPatches =true;
        xwayland.enable = true;
      };
    }
  ];
}