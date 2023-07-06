{ pkgs, ... }: {
  hardware = {
    sane = {
      enable = false;
      extraBackends = with pkgs; [ hplipWithPlugin sane-airscan ];
    };
  };
}
