{
  config,
  lib,
  ...
}: let
  browser = ["firefox.desktop"];
  archiveManager = ["org.gnome.FileRoller.desktop"];

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

    "audio/*" = ["mpv.desktop"];
    "video/*" = ["mpv.dekstop"];
    #"image/*" = ["feh.desktop"];
    "image/*" = ["imv.desktop"];

    "application/json" = browser;

    "application/pdf" = ["org.pwmt.zathura.desktop.desktop"];

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
      enable = lib.mkDefault true;
      createDirectories = lib.mkDefault true;
      desktop = lib.mkDefault "${config.home.homeDirectory}/desktop";
      documents = lib.mkDefault "${config.home.homeDirectory}/documents";
      download = lib.mkDefault "${config.home.homeDirectory}/downloads";
      music = lib.mkDefault "${config.home.homeDirectory}/music";
      pictures = lib.mkDefault "${config.home.homeDirectory}/pictures";
      wallpapers = lib.mkDefault "${config.home.homeDirectory}/wallpapers";
      publicShare = lib.mkDefault "${config.home.homeDirectory}/public";
      templates = lib.mkDefault "${config.home.homeDirectory}/templates";
      videos = lib.mkDefault "${config.home.homeDirectory}/videos";
      extraConfig = {
        XDG_SCREENSHOTS_DIR = lib.mkDefault "${config.home.homeDirectory}/pictures/screenshots";
        XDG_WALLPAPERS_DIR = lib.mkDefault "${config.home.homeDirectory}/wallpapers";
        XDG_CONTAINERS_DIR = lib.mkDefault "${config.home.homeDirectory}/containers-data";
        XDG_WORKSPACE_DIR = lib.mkDefault "${config.home.homeDirectory}/workspace";
      };
    };
  };
}
