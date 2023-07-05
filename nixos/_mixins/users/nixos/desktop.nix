{ desktop, lib, pkgs, username, ... }: {
  config.system.activationScripts.installerDesktop = let
    homeDir = "/home/${username}/";
    desktopDir = homeDir + "Desktop/";
  in ''
    mkdir -p ${desktopDir}
    chown ${username} ${homeDir} ${desktopDir}
    ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${
      desktopDir + "gparted.desktop"
    }
    ln -sfT ${pkgs.pantheon.elementary-terminal}/share/applications/io.elementary.terminal.desktop ${
      desktopDir + "io.elementary.terminal.desktop"
    }
    ln -sfT ${pkgs.calamares-nixos}/share/applications/io.calamares.calamares.desktop ${
      desktopDir + "io.calamares.calamares.desktop"
    }
  '';

  config = {
    services.kmscon.autologinUser = lib.mkForce null;
    isoImage.edition = lib.mkForce "${desktop}";
    services.xserver = {
      displayManager.autoLogin.user = "${username}";
      libinput.enable = true;
      libinput.touchpad = {
        horizontalScrolling = true;
        naturalScrolling = true;
        tapping = true;
        tappingDragLock = false;
      };
    };
  };

  #environment.variables = {
  #  # Firefox fixes
  #  MOZ_X11_EGL = "1";
  #  MOZ_USE_XINPUT2 = "1";
  #  MOZ_DISABLE_RDD_SANDBOX = "1";

  #  # SDL Soundfont
  #  SDL_SOUNDFONTS = LT.constants.soundfontPath pkgs;

  #  # Webkit2gtk fixes
  #  WEBKIT_DISABLE_COMPOSITING_MODE = "1";
  #};
}
