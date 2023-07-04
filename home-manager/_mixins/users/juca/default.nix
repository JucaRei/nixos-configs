{ lib, hostname, username, ... }: {
  imports = [ ]
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix"))
    ./hosts/${hostname}.nix;
  #home.file.".face".source = ./face.png;
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
    #file.".face".source = ./face.png;
    #file."Development/debian/.envrc".text = "export DEB_VENDOR=Debian";
    #file."Development/ubuntu/.envrc".text = "export DEB_VENDOR=Ubuntu";
    #file.".ssh/config".text = "
    #  Host github.com
    #    HostName github.com
    #    User git

    #  Host man
    #    HostName man.wimpress.io

    #  Host yor
    #    HostName yor.wimpress.io

    #  Host man.ubuntu-mate.net
    #    HostName man.ubuntu-mate.net
    #    User matey
    #    IdentityFile ~/.ssh/id_rsa_semaphore

    #  Host yor.ubuntu-mate.net
    #    HostName yor.ubuntu-mate.net
    #    User matey
    #    IdentityFile ~/.ssh/id_rsa_semaphore

    #  Host bazaar.launchpad.net
    #    User flexiondotorg

    #  Host git.launchpad.net
    #    User flexiondotorg

    #  Host ubuntu.com
    #    HostName people.ubuntu.com
    #    User flexiondotorg

    #  Host people.ubuntu.com
    #    User flexiondotorg

    #  Host ubuntupodcast.org
    #    HostName live.ubuntupodcast.org
    #";
    #file."Quickemu/nixos.conf".text = ''
    #  #!/run/current-system/sw/bin/quickemu --vm
    #  guest_os="linux"
    #  disk_img="nixos/disk.qcow2"
    #  disk_size="96G"
    #  iso="nixos/nixos.iso"
    #'';
    #file."Quickemu/nixos-mini.conf".text = ''
    #  #!/run/current-system/sw/bin/quickemu --vm
    #  guest_os="linux"
    #  disk_img="nixos-mini/disk.qcow2"
    #  disk_size="96G"
    #  iso="nixos-mini/nixos.iso"
    #'';
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
    "d /home/${username}/workspace/linux 0755 ${username} users - -"
    "d /home/${username}/workspace/virtualmachines 0755 ${username} users - -"
    "d /home/${username}/workspace/docker-configs 0755 ${username} users - -"
    "d /home/${username}/workspace/lab 0755 ${username} users - -"
    "d /home/${username}/workspace/github 0755 ${username} users - -"
    "d /home/${username}/workspace/bitbucket 0755 ${username} users - -"
    "d /home/${username}/workspace/gitlab 0755 ${username} users - -"
    "d /home/${username}/games 0755 ${username} users - -"
    "d /home/${username}/quickemu 0755 ${username} users - -"
    "d /home/${username}/scripts 0755 ${username} users - -"
    "d /home/${username}/syncthing 0755 ${username} users - -"
    "d /home/${username}/websites 0755 ${username} users - -"
    "d /home/${username}/Zero 0755 ${username} users - -"
  ];
}

