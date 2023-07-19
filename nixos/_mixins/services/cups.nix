{pkgs, ...}: {
  imports = [./avahi.nix];
  services = {
    printing = {
      enable = false; # enable if needed
      drivers = with pkgs;
      #[ gutenprint hplipWithPlugin ];
        [gutenprint];
      cups-pdf = {
        enable = false;
      };
    };
  };
}
