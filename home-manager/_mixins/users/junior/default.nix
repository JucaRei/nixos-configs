{
  lib,
  hostname,
  username,
  ...
}: {
  imports =
    []
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix"))
    ./hosts/${hostname}.nix;

  home = {
    #file.".bazaar/authentication.conf".text = "
    #  [Launchpad]
    #  host = .launchpad.net
    #  scheme = ssh
    #  user = flexiondotorg
    #";
    #file.".bazaar/bazaar.conf".text = "
    #  [DEFAULT]
    #  email = Martin Wimpress <code@wimpress.io>
    #  launchpad_username = flexiondotorg
    #  mail_client = default
    #  tab_width = 4
    #  [ALIASES]
    #";
    file.".distroboxrc".text = "\n      xhost +si:localuser:$USER\n    ";
    file.".face".source = ./face.jpg;
    #file."Development/debian/.envrc".text = "export DEB_VENDOR=Debian";
    #file."Development/ubuntu/.envrc".text = "export DEB_VENDOR=Ubuntu";
    file.".ssh/config".text = "\n      Host github.com\n        HostName github.com\n        User git\n\n    #  Host man\n    #    HostName man.wimpress.io\n\n    #  Host yor\n    #    HostName yor.wimpress.io\n\n    #  Host man.ubuntu-mate.net\n    #    HostName man.ubuntu-mate.net\n    #    User matey\n    #    IdentityFile ~/.ssh/id_rsa_semaphore\n\n    #  Host yor.ubuntu-mate.net\n    #    HostName yor.ubuntu-mate.net\n    #    User matey\n    #    IdentityFile ~/.ssh/id_rsa_semaphore\n\n    #  Host bazaar.launchpad.net\n    #    User flexiondotorg\n\n    #  Host git.launchpad.net\n    #    User flexiondotorg\n\n    #  Host ubuntu.com\n    #    HostName people.ubuntu.com\n    #    User flexiondotorg\n\n    #  Host people.ubuntu.com\n    #    User flexiondotorg\n\n    #  Host ubuntupodcast.org\n    #    HostName live.ubuntupodcast.org\n    #";
    file."Quickemu/nixos.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos/disk.qcow2"
      disk_size="20G"
      iso="nixos/nixos.iso"
    '';
    file."Quickemu/nixos-mini.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-mini/disk.qcow2"
      disk_size="13G"
      iso="nixos-mini/nixos.iso"
    '';
    #sessionVariables = {
    #  BZR_EMAIL = "Martin Wimpress <code@wimpress.io>";
    #  DEBFULLNAME = "Martin Wimpress";
    #  DEBEMAIL = "code@wimpress.io";
    #  DEBSIGN_KEYID = "8F04688C17006782143279DA61DF940515E06DA3";
    #};
  };
  programs = {
    git = {
      userEmail = "reinaldo800@gmail.com";
      userName = "Reinaldo P Jr";
      signing = {
        key = "7A53AFDE4EF7B526";
        signByDefault = true;
      };
    };
  };

  systemd.user.tmpfiles.rules = [
    "d /home/${username}/Documents/workspace/linux 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/virtualmachines 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/docker-configs 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/lab 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/github 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/bitbucket 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/gitlab 0755 ${username} users - -"
    "d /home/${username}/Documents/workspace/scripts/ 0755 ${username} users - -"
    "d /home/${username}/games 0755 ${username} users - -"
    "d /home/${username}/quickemu/nixos 0755 ${username} users - -"
    "d /home/${username}/quickemu/nixos-mini 0755 ${username} users - -"
    "d /home/${username}/syncthing 0755 ${username} users - -"
    "d /home/${username}/Zero 0755 ${username} users - -"
  ];
}
