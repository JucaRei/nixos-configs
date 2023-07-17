{ lib
, ...
}:
with lib.hm.gvariant; {
  # SMB Shares
  services.samba = {
    enable = true;
    syncPasswordsByPam = true;
    shares = {
      shared = {
        path = "/data/shared";
        public = false;
        writable = true;
      };
    };
    extraConfig = ''
      # login to guest if login fails
      map to guest = Bad User
      # fix error with no printers
      load printers = no
      printcap name = /dev/null
      printing = bsd
    '';
  };
}
