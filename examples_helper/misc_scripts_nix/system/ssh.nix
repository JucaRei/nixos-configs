# SSH NixOS bootstrap
_: {
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "yes";
  };

  users.users."root".openssh.authorizedKeys.keys = [
    # kramacbook
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBV4ZjlUvRDs70qHD/Ldi6OTkFpDEFgfbXbqSnaL2Qup"

    # dev.ntnu vm
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyrauaLwnrgeR5mpeOBCw/creVh1dMU1a12TTXvQ+Rd"

    # kraairm2
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGqesfGzltPA+pNVQ667T1tKzQoz09qTcoQshygxl73I3EbYD5vnHFtC+tnziVbfxSx8ZDRvPDN7vHEalE5U3JU="
  ];

  networking.firewall.enable = false;
}
