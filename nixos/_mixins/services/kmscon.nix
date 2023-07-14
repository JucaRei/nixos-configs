{ pkgs, ... }: {
  services = {
    kmscon = {
      enable = true;
      hwRender = true;
      # Configure kmscon fonts via extraConfig so that we can use Nerd Fonts
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; });
      }];
      extraConfig = ''
        font-size=14
        xkb-layout=us
      '';
    };
  };
}
