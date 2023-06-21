source "virtualbox-iso" "nixos" {
  headless      = true
  cpus          = 4
  memory        = 8192
  guest_os_type = "Linux_64"

  # if you change the image, you'll need to change the checksum as well
  iso_url      = "https://channels.nixos.org/nixos-22.11/latest-nixos-minimal-x86_64-linux.iso"
  iso_checksum = "md5:f6f7133f0946c288287c8f888c4d9dba"

  # set the password so the shell provisioner can run
  boot_wait    = "3s"
  boot_command = [
    "<enter><wait30s>",
    "passwd<enter><wait100ms>",
    "nixos<enter><wait100ms>",
    "nixos<enter><wait100ms>",
  ]

  # config for the shell provisioner
  communicator     = "ssh"
  ssh_username     = "nixos"
  ssh_password     = "nixos"
  shutdown_command = "sudo shutdown -h now"

  # we'll be building an ISO inside this VM and then throwing away the VM itself
  skip_export = true
}

build {
  sources = ["sources.virtualbox-iso.nixos"]

  # pull in the .nix file that describes how to build a NixOS ISO
  provisioner "file" {
    source      = "iso.nix"
    destination = "/home/nixos/iso.nix"
  }

  # build the NixOS ISO
  provisioner "shell" {
    execute_command = "echo 'nixos' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline          = [
      "cd /home/nixos",
      "nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix",
    ]
  }

  # copy it out to the host
  provisioner "file" {
    source      = "/home/nixos/result/iso/nixos-22.11.2315.13fdd3945d8-x86_64-linux.iso"
    destination = "nixos-22.11.2315.13fdd3945d8-x86_64-linux.iso"
    direction   = "download"
  }
}