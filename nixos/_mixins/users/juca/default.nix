{ config, desktop, lib, pkgs, ... }:
let
  ifExists = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Only include desktop components if one is supplied.
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  environment.systemPackages = with pkgs;
    [
      yadm # Terminal dot file manager
    ];

  users.users.juca = {
    description = "Reinaldo P JR";
    extraGroups = [ "audio" "networkmanager" "users" "video" "wheel" ]
      ++ ifExists [
        "docker"
        "podman"
        "adbusers"
        "network"
        "wireshark"
        "lxd"
        "git"
        "libvirtd"
      ];
    # mkpasswd -m sha-512
    hashedPassword =
      "$6$nmx8IpxHWpKjbT7O$R4RqA4sUDdCLmt.pO1w3.YAIje4/DPFcmj.a5hsdEzkekGPrgAEpEDyMK2Yotv.nZ9bnu5wuWEE7n0B6EL/ik1";
    homeMode = "0755";
    isNormalUser = true;
    createHome = true;
    autoSubUidGidRange =
      true; # Allocated range is currently always of size 65536
    uid = 1000;
    initialPassword =
      "password"; # remember of changing the password when log in.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC2gvi32T+zdS+0sQNDeiJ8V6JOBO2Nf7glTKIdWrYXEnqbhroxcIOakDA7FkAqXbhNCQLhBakSD8f/lMkWzBddgdrU7tgdOi20CHzbQ9qz23bA6CNXjrqfZY84jjgKJv3PJj51pZYWNvle6fiZ3qeTfdbsa7b+9Mfnwzvq6yypS5lVYbzjIH0W1dto9m8Tw8J/5093Hagcja+je+Whyk6RuSf3CzmvY8DsL/XwS/f+JZjnpsiPr4xJ3mXtQm5R8lKy2NQDAObznjh7ptjogo9iY7Q6L4L5+lXqciaYmu8gr1Ht+QifODgNC/xSJqUDpti3/4Qh1hjczzFH+P6Mc2RVuHmi5X0yhKLWVrwp1dsWr7LAXc6tadaDpSnifqLjvhO3FHYMLEs+NHtvh+N+Aos7aDEmtVl9wEl+Tjrr08FFRuW4N2WHZtBVUuvBZoTbpgbVgjWVcLOFqLu46Y2xo+Lv9tr2DlV+fjVdR4EvV4SC20yC2cyLo78SWH7TgO71F+knk/7eU7ITyT64HPD7pbEvQ5J4Sk7Hr7u5XWfM/wOM0Ot/gxTQYj9kNdx79Tj5Sd3UzGxaZfLUpUXPhBEs1S9/d8hHUCVgKmloXkfetBqLteRE8vjIxAQbO5TG54qM6Bvc7e8ut53BrRDzeZIg28zWq6mesoaCucfFTvh8ZyxMQ== juca@nitro"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
