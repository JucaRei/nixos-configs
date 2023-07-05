#!/usr/bin/env bash

tmp_dir="$(mktemp -d)"
btrfs_map_physical="$tmp_dir/btrfs_map_physical"
mkdir scripts && cd scripts
curl -LJO https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c
gcc -O2 -o "$btrfs_map_physical" ./scripts/btrfs_map_physical.c
physical_offset="$(sudo "$btrfs_map_physical" /swap/swapfile | cut -f9 | head -n2 | tail -n1)"
pagesize="$(getconf PAGESIZE)"
resume_offset=$((physical_offset / pagesize))
rm -r "$tmp_dir"
echo "resume_offset=$resume_offset"

# nix-shell -p pkgconfig gcc openssl