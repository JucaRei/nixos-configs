#!/usr/bin/env nix-shell
#! nix-shell -i sh -p nix

set -e

ROOT="$1"; shift

USER_MOUNTS=$(nix-build --no-out-link shell.nix -A user-mounts)
ZSH=$(nix-build --no-out-link "<nixpkgs>" -A zsh)
CU=$(nix-build --no-out-link "<nixpkgs>" -A coreutils)
UL=$(nix-build --no-out-link "<nixpkgs>" -A utillinux)
NIX=$(nix-build --no-out-link "<nixpkgs>" -A nix)
SUDO=$(nix-build --no-out-link "<nixpkgs>" -A sudo)

nix copy --no-check-sigs --to local?root=$ROOT $USER_MOUNTS $ZSH $NIX $CU $SUDO $UL

exec $USER_MOUNTS/bin/unshare-user-mounts "
mount --make-rprivate /
mount --rbind $ROOT/nix /nix
export PATH='$ZSH/bin:$NIX/bin:$CU/bin:$SUDO/bin:$UL/bin'
" "$@"
