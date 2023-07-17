{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.nixfiles.modules.games.steam-run;
in
{
  options.nixfiles.modules.games.steam-run = {
    enable = mkEnableOption "Whether to enable native Steam runtime.";

    quirks = {
      mountandblade = mkEnableOption "Fix \"Mount & Blade: Warband\" issues.";
    };
  };

  config = mkIf cfg.enable {
    nixfiles.modules = {
      games = {
        enable32BitSupport = mkForce true;
        gamemode.enable = mkForce true;
      };
    };

    hm.home.packages = with pkgs; [
      (steam.override {
        extraLibraries = _:
          with cfg.quirks;
          optionals mountandblade [
            (glew.overrideAttrs (_: super:
              let
                opname = super.pname;
              in
              rec {
                pname = "${opname}-mountandblade";
                inherit (super) version;
                src = fetchurl {
                  url = "mirror://sourceforge/${opname}/${opname}-${version}.tgz";
                  sha256 = "sha256-BN6R5+Z2MDm8EZQAlc2cf4gLq6ghlqd2X3J6wFqZPJU=";
                };
              }))
            (fmodex.overrideAttrs (_: super:
              let
                opname = super.pname;
              in
              rec {
                pname = "${opname}-mountandblade";
                inherit (super) version;
                installPhase =
                  let
                    libPath = makeLibraryPath [
                      alsa-lib
                      libpulseaudio
                      stdenv.cc.cc
                    ];
                  in
                  ''
                    install -Dm755 api/lib/libfmodex64-${version}.so $out/lib/libfmodex64.so
                    patchelf --set-rpath ${libPath} $out/lib/libfmodex64.so
                  '';
              }))
          ];
      }).run
    ];
  };
}
