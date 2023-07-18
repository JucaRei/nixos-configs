{
  inputs = {mrkuz.url = "github:mrkuz/nixos";};
  outputs = {
    mrkuz,
    nixpkgs,
  }: let
    name = "lxd";
    system = "x86_64-linux";
    nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs.profilesPath = "${mrkuz}/profiles";
      modules = mrkuz.utils.mkNixOSModules {
        inherit name system;
        extraModules = [./configuration.nix];
      };
    };
  in {packages."${system}".default = nixos.config.system.build.lxdImport;};
}
