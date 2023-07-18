{username, ...}: {
  services.samba = {
    enable = true;
    shares = {
      "path" = "/home/${username}";
      "guest ok" = "yes";
      "ready only" = "no";
    };
  };
}
