{ pkgs, lib,desktop, ... }: {
    imports = [ ] ++ lib.optional (builtins.isString desktop) ../desktop/simple-scan.nix;

  hardware = {
    sane = {
      enable = false;
      extraBackends = with pkgs; [ 
        hplipWithPlugin 
        sane-airscan 
      ];
    };
  };
}
