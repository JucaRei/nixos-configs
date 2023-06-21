{
  config,
  desktop,
  lib,
  pkgs,
  username,
  ...
}: let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Only include desktop components if one is supplied.
  imports =
    [
      ./packages-console.nix
    ]
    ++ lib.optional (builtins.isString desktop) ./packages-desktop.nix;

  config.users.users.nixos = {
    description = "NixOS";
    extraGroups =
      [
        "audio"
        "networkmanager"
        "users"
        "video"
        "wheel"
      ]
      ++ ifExists [
        "docker"
        "podman"
        "adbusers"
        "network"
        "wireshark"
        "git"
        "libvirtd"
      ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC2gvi32T+zdS+0sQNDeiJ8V6JOBO2Nf7glTKIdWrYXEnqbhroxcIOakDA7FkAqXbhNCQLhBakSD8f/lMkWzBddgdrU7tgdOi20CHzbQ9qz23bA6CNXjrqfZY84jjgKJv3PJj51pZYWNvle6fiZ3qeTfdbsa7b+9Mfnwzvq6yypS5lVYbzjIH0W1dto9m8Tw8J/5093Hagcja+je+Whyk6RuSf3CzmvY8DsL/XwS/f+JZjnpsiPr4xJ3mXtQm5R8lKy2NQDAObznjh7ptjogo9iY7Q6L4L5+lXqciaYmu8gr1Ht+QifODgNC/xSJqUDpti3/4Qh1hjczzFH+P6Mc2RVuHmi5X0yhKLWVrwp1dsWr7LAXc6tadaDpSnifqLjvhO3FHYMLEs+NHtvh+N+Aos7aDEmtVl9wEl+Tjrr08FFRuW4N2WHZtBVUuvBZoTbpgbVgjWVcLOFqLu46Y2xo+Lv9tr2DlV+fjVdR4EvV4SC20yC2cyLo78SWH7TgO71F+knk/7eU7ITyT64HPD7pbEvQ5J4Sk7Hr7u5XWfM/wOM0Ot/gxTQYj9kNdx79Tj5Sd3UzGxaZfLUpUXPhBEs1S9/d8hHUCVgKmloXkfetBqLteRE8vjIxAQbO5TG54qM6Bvc7e8ut53BrRDzeZIg28zWq6mesoaCucfFTvh8ZyxMQ== juca@nitro"
    ];
    packages = [pkgs.home-manager];
    shell = pkgs.fish;
  };

  config.system.activationScripts.installerDesktop = let
    # Comes from documentation.nix when xserver and nixos.enable are true.
    manualDesktopFile = "/run/current-system/sw/share/applications/nixos-manual.desktop";
    homeDir = "/home/${username}/";
    desktopDir = homeDir + "Desktop/";
  in ''
    mkdir -p ${desktopDir}
    chown ${username} ${homeDir} ${desktopDir}
    ln -sfT ${manualDesktopFile} ${desktopDir + "nixos-manual.desktop"}
    ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
    ln -sfT ${pkgs.pantheon.elementary-terminal}/share/applications/io.elementary.terminal.desktop ${desktopDir + "io.elementary.terminal.desktop"}
    ln -sfT ${pkgs.calamares-nixos}/share/applications/io.calamares.calamares.desktop ${desktopDir + "io.calamares.calamares.desktop"}
  '';

  config.isoImage.edition = lib.mkForce "${desktop}";
  config.system.stateVersion = lib.mkForce lib.trivial.release;
  config.services.xserver.displayManager.autoLogin.user = "${username}";
}
