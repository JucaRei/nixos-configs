{ pkgs, config, lib, ... }: let m = 60; h = 60*m; d = 24*h; y = 365*d; in {
  programs.gpg = {
    enable = true;
    #dirmngr.enable = false;
    settings = {
      default-key = "3868 E14C 17FE 4F20 86C2  1A6F 3EE4 4BE6 8AF1 8D09";
      default-recipient-self = true;
      #auto-key-locate = "local,wkd,keyserver";
      #keyserver = "https://keys.openpgp.org";
      #auto-key-retrieve = true;
      #auto-key-import = true;
      #keyserver-options = "honor-keyserver-url";
    };
   # agent = {
   #   enable = true;
   #   # allows web browsers to access the gpg-agent daemon
   #   #enableBrowserSocket = false;
   #   # NOTE: "gnome3" flavor only works with Xorg
   #   # To reload config: gpg-connect-agent reloadagent /bye
   #   #pinentryFlavor = "gtk2"; # use "tty" for console only
   #   #pinentryFlavor = "cursers";
   #   # cache SSH keys added by the ssh-add
   #   #enableSSHSupport = false;
   #   # set up a Unix domain socket forwarding from a remote system
   #   # enables to use gpg on the remote system without exposing the private keys to the remote system
   #   enableExtraSocket = false;
   #   enableBrowserSocket = false;
   #   defaultCacheTtl = 34560000;
   #   defaultCacheTtlSsh = 34560000;
   #   #maxCacheTtl = 34560000;
   #   #maxCacheTtlSsh = 34560000;
   #   maxCacheTtl = 100*y; # effectively unlimited
   #   maxCacheTtlSsh = 100*y; # effectively unlimited
   # };
  };

   services.gpg-agent = {
   #   enable = true;
   #   enableSshSupport = true;
   #   enableExtraSocket = true;
      ##updateStartupTty = false;
   #   defaultCacheTtl = 6*h;
   #   defaultCacheTtlSsh = 6*h;
   #   maxCacheTtl = 100*y; # effectively unlimited
   #   maxCacheTtlSsh = 100*y; # effectively unlimited
   #   sshKeys = [ "7A53AFDE4EF7B526" ];
   #   extraConfig = ''
   #    Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
   #  '';

      pinentryFlavor = "tty";  #curses
   };

   # to avoid The `busctl monitor` error
  # "name org.freedesktop.secrets was not provided by any .service files"
  #programs.password-store = {
  #  enable = true;
  #  package = pkgs.pass; #.withExtensions (ext: [ ext.pass-otp ]);
  #  settings = {
  #    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
  #  };
  #};

  #services.pass-secret-service.enable = true;
  #systemd.user.services.pass-secret-service = {
  #  Service = {
  #    Type = "dbus";
  #    BusName = "org.freedesktop.secrets";
  #    ExecStart = lib.mkForce "${pkgs.pass-secret-service}/bin/pass_secret_service --path ${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
  #  };
  #};

  #NIXOS

 # # relevant part of nixos configuration
 # environment.systemPackages = with pkgs; [
 #   pass-secret-service
 # ];
 # services.dbus = {
 #   packages = [
 #     pkgs.pass-secret-service
 #   ];
 # };
 # services.pcscd.enable = true;
#
 # # removed all gpg-agent related configuration
 # programs.keychain = {
 #   enable = true;
 #   keys = [ "id_ed25519" ];
 #   # Each time I need to add new key, I just type keychain path/to/key.
 # };

  home.packages = [ pkgs.gnupg ];
}
