{ inputs, outputs, stateVersion, ... }:let
systems = [
  "aarch64-linux"
  "i686-linux"
  "x86_64-linux"
  "aarch64-darwin"
  "x86_64-darwin"
];
in {
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, platform ? builtins.listToAttrs (builtins.map(s: { name = s; }) systems) }: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules = [ ../home-manager ];
    };

  # Helper function for generating host configs
  mkHost = { hostname, username, desktop ? null, hostid ? null, installer ? null }: inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname username hostid stateVersion;
      };
      modules = [ ../nixos ] ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ]);
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
  # Like mkEnableOption, just enable the option by default instead
  #mkDefaultOption = name: lib.mkEnableOption name // { default = true; };
}
