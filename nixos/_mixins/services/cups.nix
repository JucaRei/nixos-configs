{pkgs, ...}: {
  imports = [
    ./avahi.nix
  ];
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplipWithPlugin
      ];
    };
  };
}
