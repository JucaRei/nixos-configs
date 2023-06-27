{pkgs, ...}: {
  programs = {
    firefox = {
      enable = true;
      package = pkgs.unstable.firefox;
    };
  };

  environment.systemPackages = with pkgs; [
    #libreoffice
    #vivaldi
    #vivaldi-ffmpeg-codecs
    vscode-fhs
  ];
}
