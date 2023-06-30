{ lib, pkgs, ... }: {
  programs = {
    firefox = {
      enable = lib.mkDefault true;
      languagePacks = [ "en-GB" "pt-BR" ];
      package = pkgs.unstable.firefox;
    };
  };
}
