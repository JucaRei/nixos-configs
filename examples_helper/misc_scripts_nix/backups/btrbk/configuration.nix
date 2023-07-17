{
  imports = [
    ./btrbk.nix
  ];

  # ... rest of the config

  services.btrbk.instances.nixos.settings = {
    snapshot_preserve = "7d";
    snapshot_preserve_min = "2d";

    target_preserve_min = "no";
    target_preserve = "20d";

    ssh_identity = "/var/lib/btrbk/id_rsa";
    ssh_user = "root";

    stream_buffer = "256m";

    volume = {
      "/home" = {
        snapshot_dir = "snapshots";
        subvolume = {
          "." = { };
        };
        target = "ssh://nas/backup/nixos";
      };
    };
  };
}
