{ config, lib, ... }:
let
  browser = [ "firefox.desktop" ];
  archiveManager = [ "org.gnome.FileRoller.desktop" ];

  # XDG MIME types
  associations = {
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "text/html" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = browser;

    "audio/*" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.dekstop" ];
    #"image/*" = ["feh.desktop"];
    "image/*" = [ "imv.desktop" ];

    "application/json" = browser;

    "application/pdf" = [ "org.pwmt.zathura.desktop.desktop" ];

    # Archives / compressed files
    "application/x-7z-compressed" = archiveManager;
    "application/x-7z-compressed-tar" = archiveManager;
    "application/x-bzip" = archiveManager;
    "application/x-bzip-compressed-tar" = archiveManager;
    "application/x-compress" = archiveManager;
    "application/x-compressed-tar" = archiveManager;
    "application/x-cpio" = archiveManager;
    "application/x-gzip" = archiveManager;
    "application/x-lha" = archiveManager;
    "application/x-lzip" = archiveManager;
    "application/x-lzip-compressed-tar" = archiveManager;
    "application/x-lzma" = archiveManager;
    "application/x-lzma-compressed-tar" = archiveManager;
    "application/x-tar" = archiveManager;
    "application/x-tarz" = archiveManager;
    "application/x-xar" = archiveManager;
    "application/x-xz" = archiveManager;
    "application/x-xz-compressed-tar" = archiveManager;
    "application/zip" = archiveManager;
    "application/gzip" = archiveManager;
    "application/bzip2" = archiveManager;
    "application/vnd.rar" = archiveManager;
  };
in {
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = associations;
    };
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
      extraConfig = {
        XDG_SCREENSHOTS_DIR =
          "${config.home.homeDirectory}/pictures/screenshots";
        XDG_WALLPAPERS_DIR = "${config.home.homeDirectory}/pictures/wallpapers";
        XDG_CONTAINERS_DIR = "${config.home.homeDirectory}/containers-data";
        XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/workspace";
        XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
        XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
        XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
        XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
      };
      extraInit = ''
        export XAUTHORITY=/tmp/Xauthority
        export xserverauthfile=/tmp/xserverauth
        [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
        [ -e ~/.serverauth.* ] && mv -f ~/.serverauth.* "$xserverauthfile"
      '';
    };
  };
}
