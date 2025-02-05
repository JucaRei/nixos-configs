{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkEnableOption mkIf mkOption;
  inherit (lib.types) int;

  cfg = config.sys2x.gc;

  script = pkgs.writeShellScriptBin "get-gc-size" ''
    read _ size used available < <(df -PBM /nix/store | tail -1)
    size=''${size%M}
    used=''${used%M}
    available=''${available%M}

    collectLimit=${toString cfg.collectLimitMiB}

    (( collectLimit < 0 )) && collectLimit=$((size - collectLimit))
    (( collectLimit < 0 )) && collectLimit=0
    fromPct=$((${toString cfg.collectLimitPercent} * size / 100))
    (( fromPct < collectLimit )) && collectLimit=$fromPct

    freeLimit=${toString cfg.freeLimitMiB}

    (( freeLimit < 0 )) && freeLimit=$((size - freeLimit))
    (( freeLimit < 0 )) && freeLimit=0
    fromPct=$((${toString cfg.freeLimitPercent} * size / 100))
    # TODO: is it better to use the larger value here instead? not sure
    (( fromPct < freeLimit )) && freeLimit=$fromPct

    if (( collectLimit < freeLimit )); then
      echo "error: collectLimit < freeLimit ($collectLimit < $freeLimit), this makes no sense" >&2
      echo 0
      exit 1
    fi

    if (( used < collectLimit )); then
      echo "collect limit not reached" >&2
      echo 0
      exit 0
    fi

    maxCollect=$((used - freeLimit))

    echo "collecting up to $maxCollect MiB" >&2
    echo $((maxCollect * 1048576))
    exit 0
  '';

  hourly =
    if pkgs.stdenv.isLinux
    then {
      dates = mkDefault "hourly";
    }
    else if pkgs.stdenv.isDarwin
    then {
      interval = mkDefault {Minute = 0;};
    }
    else throw "unsupported system";
in {
  options = {
    sys2x.gc = {
      useDiskAware = mkEnableOption "disk-aware garbage collector";

      collectLimitPercent = mkOption {
        description = "Maximum disk usage before GC is triggered in %";
        type = int;
        default = 90;
      };

      collectLimitMiB = mkOption {
        description = "Maximum disk usage before GC is triggered in MiB (negative values: SIZE-x)";
        type = int;
        default = -8192;
      };

      freeLimitPercent = mkOption {
        description = "Target size in %";
        type = int;
        default = 50;
      };

      freeLimitMiB = mkOption {
        description = "Target size in MiB (negative values: SIZE-x)";
        type = int;
        default = -16384;
      };
    };
  };

  config = mkIf cfg.useDiskAware {
    nix.gc =
      {
        automatic = mkDefault true;
        options = ''--max-freed "$(${script}/bin/get-gc-size)"'';
      }
      // hourly;
  };
}
# Module to set disk space limits for the automatic garbage collector
#You can set the upper limit (i.e. how full the disk needs to be for it to start collecting)
# and lower limit (i.e. up to which capacity is freed) both in % of disk size and free/used MiB.
#this still periodically calls nix-collect-garbage regardless of whether the limit is hit, but
#if it isn't, it passes --max-freed 0 which will only delete dead gcroots, which is very convenient.

