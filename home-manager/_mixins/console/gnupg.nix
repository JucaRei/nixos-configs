{ pkgs, ... }: {
  gpg = {
    enable = false; # disabled for now
    dirmngr.enable = false;
    agent = {
      enable = false;
      # allows web browsers to access the gpg-agent daemon
      #enableBrowserSocket = false;
      # NOTE: "gnome3" flavor only works with Xorg
      # To reload config: gpg-connect-agent reloadagent /bye
      #pinentryFlavor = "gtk2"; # use "tty" for console only
      pinentryFlavor = "cursers";
      # cache SSH keys added by the ssh-add
      enableSSHSupport = false;
      # set up a Unix domain socket forwarding from a remote system
      # enables to use gpg on the remote system without exposing the private keys to the remote system
      enableExtraSocket = false;
      enableBrowserSocket = false;
      defaultCacheTtl = 34560000;
      defaultCacheTtlSsh = 34560000;
      maxCacheTtl = 34560000;
      maxCacheTtlSsh = 34560000;
    };
  };
  home.packages = [ pkgs.gnupg ];
}
