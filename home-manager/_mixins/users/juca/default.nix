{ lib, hostname, ... }: {
  imports = [ ] ++ lib.optional (builtins.pathExists (./. + "/${hostname}.nix"))
    ./${hostname}.nix;
  #home.file.".face".source = ./face.png;
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
}
