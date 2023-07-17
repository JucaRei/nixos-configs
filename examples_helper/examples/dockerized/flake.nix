{
  inputs = {
    mrkuz.url = "github:mrkuz/nixos";
  };
  outputs =
    { mrkuz
    , nixpkgs
    ,
    }:
    let
      name = "dockerized";
      system = "x86_64-linux";
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs.profilesPath = "${mrkuz}/profiles";
        modules = mrkuz.utils.mkNixOSModules {
          inherit name system;
          extraModules = [ ./configuration.nix ];
        };
      };
    in
    {
      packages."${system}".default = nixos.config.system.build.dockerTar;
    };
}
