Crostini NixOS LXC Configuration
  { config
  , modulesPath
  , pkgs
  , ...
  }: {
    imports = [
      (modulesPath + "/virtualisation/lxc-container.nix")
    ];

    services.openssh.enable = true;
    programs.xwayland.enable = true;

    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    users.users.brainwart = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialHashedPassword = "";
    };

    environment.systemPackages = with pkgs; [
      unixtools.xxd
      xorg.xauth
      xkeyboard_config
      xdg-utils
      xorg.xdpyinfo
      xorg.xrdb
      xorg.xsetroot
      dbus

      (vim_configurable.override { config.vim.gui = false; })
      libnotify
      wget
      tmux
    ];

    systemd.user.services."sommelier@0" = {
      enable = true;
      description = "Parent sommelier listening on socket wayland-0";
      environment = {
        WAYLAND_DISPLAY_VAR = "WAYLAND_DISPLAY";
        SOMMELIER_SCALE = "1.0";
      };

      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "notify";
        Restart = "always";
      };
      preStart = ''      /bin/sh -c \
      "/run/current-system/sw/bin/test -c /dev/dri/renderD128 && \
       /run/current-system/sw/bin/systemctl --user set-environment \
         SOMMELIER_DRM_DEVICE=/dev/dri/renderD128; \
       /run/current-system/sw/bin/true"
    '';
      script = ''      /opt/google/cros-containers/bin/sommelier --parent \
      --sd-notify="READY=1" \
      --socket=wayland-0 \
      /bin/sh -c \
        "systemctl --user set-environment ''${WAYLAND_DISPLAY_VAR}=$''${WAYLAND_DISPLAY}; \
         systemctl --user import-environment SOMMELIER_VERSION"
    '';
    };

    systemd.user.services."sommelier-x@0" = {
      enable = true;
      description = "X11 sommelier display at 0";
      environment = {
        DISPLAY_VAR = "DISPLAY";
        XCURSOR_SIZE_VAR = "XCURSOR_SIZE";
        SOMMELIER_SCALE = "1.0";
      };

      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "notify";
        Restart = "always";
      };
      preStart = ''       /bin/sh -c \
      "/run/current-system/sw/bin/test -c /dev/dri/renderD128 && \
         /run/current-system/sw/bin/systemctl --user set-environment \
           SOMMELIER_DRM_DEVICE=/dev/dri/renderD128 \
           SOMMELIER_GLAMOR=1; \
       /run/current-system/sw/bin/true"
    '';
      script = ''      /opt/google/cros-containers/bin/sommelier -X \
        --x-display=0 \
        --sd-notify="READY=1" \
        --no-exit-with-child \
        --x-auth=''${HOME}/.Xauthority \
        /bin/sh -c \
            "systemctl --user set-environment ''${DISPLAY_VAR}=$''${DISPLAY}; \
             systemctl --user set-environment ''${XCURSOR_SIZE_VAR}=$''${XCURSOR_SIZE}; \
             systemctl --user import-environment SOMMELIER_VERSION; \
             touch ''${HOME}/.Xauthority; \
             xauth -f ''${HOME}/.Xauthority add ''${HOST}:0 . $(xxd -l 16 -p /dev/urandom); \
             . /etc/sommelierrc"
    '';
    };

    systemd.user.services."cros-notificationd" = {
      enable = true;
      description = "Chromium OS Notification Server";
      serviceConfig = {
        BusName = "org.freedesktop.Notifications";
        Type = "dbus";
        Restart = "always";
      };
      script = "/opt/google/cros-containers/bin/notificationd";
      scriptArgs = "--virtwl_device=/dev/wl0";
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    documentation.enable = true;
    documentation.man.enable = true;
    documentation.nixos.enable = true;

    system.copySystemConfiguration = true;

    system.stateVersion = "22.05";
  }
