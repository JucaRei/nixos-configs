{
  pkgs,
  lib,
  ...
}:
with lib; {
  config = {
    i18n.defaultLocale = "de_DE.UTF-8";
    time.timeZone = "Europe/Paris";

    services = {
      timesyncd.enable = lib.mkDefault true;
      openssh = {
        enable = true;
        permitRootLogin = "yes";
      };
    };

    environment.systemPackages = with pkgs; [
      dosfstools
      vim
      netcat
      curl
      openjdk8
    ];

    users.extraUsers.root.password = "";
    users.mutableUsers = false;

    users.users.root = {
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = ["ssh-rsa ... "];
    };

    # to keep usbstick booting, see https://github.com/NixOS/nixpkgs/issues/7132
    #isoImage.volumeID = lib.mkDefault "NIXOS_ISO  ";

    isoImage.contents = [
      {
        source = /home/me/kubrick;
        target = "/kubrick";
      }
    ];
  };
}
