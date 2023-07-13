{ config, desktop, lib, pkgs, username, ...}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  install-system = pkgs.writeScriptBin "install-system" ''
#!${pkgs.stdenv.shell}

#set -euo pipefail

TARGET_HOST="''${1:-}"
TARGET_USER="''${2:-juca}"

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi

if [ ! -d "$HOME/Zero/nix-config/.git" ]; then
  git clone https://github.com/JucaRei/nixos-configs.git "$HOME/Zero/nix-config"
fi

pushd "$HOME/Zero/nix-config"

if [[ -z "$TARGET_HOST" ]]; then
  echo "ERROR! $(basename "$0") requires a hostname as the first argument"
  echo "       The following hosts are available"
  ls -1 nixos/*/boot.nix | cut -d'/' -f2 | grep -v iso
  exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
  echo "ERROR! $(basename "$0") requires a username as the second argument"
  echo "       The following users are available"
  ls -1 nixos/_mixins/users/ | grep -v -E "nixos|root"
  exit 1
fi

#if [ ! -e "nixos/$TARGET_HOST/disks.nix" ]; then
#  echo "ERROR! $(basename "$0") could not find the required nixos/$TARGET_HOST/disks.nix"
#  exit 1
#fi

# Check if the machine we're provisioning expects a keyfile to unlock a disk.
# If it does, generate a new key, and write to a known location.
if grep -q "data.keyfile" "nixos/$TARGET_HOST/disks.nix"; then
  echo -n "$(head -c32 /dev/random | base64)" > /tmp/data.keyfile
fi

echo "WARNING! The disks in $TARGET_HOST are about to get wiped"
echo "         NixOS will be re-installed"
echo "         This is a destructive operation"
echo
read -p "Are you sure? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo true

#  sudo nix run github:nix-community/disko \
#    --extra-experimental-features "nix-command flakes" \
#    --no-write-lock-file \
#    -- \
#    --mode zap_create_mount \
#    "nixos/$TARGET_HOST/disks.nix"

  sudo nixos-install --no-root-password --flake ".#$TARGET_HOST"

  # Rsync nix-config to the target install and set the remote origin to SSH.
  rsync -a --delete "$HOME/Zero/" "/mnt/home/$TARGET_USER/Zero/"
  pushd "/mnt/home/$TARGET_USER/Zero/nix-config"
  git remote set-url origin git@github.com:JucaRei/nixos-configs.git
  popd

  # If there is a keyfile for a data disk, put copy it to the root partition and
  # ensure the permissions are set appropriately.
  if [[ -f "/tmp/data.keyfile" ]]; then
    sudo cp /tmp/data.keyfile /mnt/etc/data.keyfile
    sudo chmod 0400 /mnt/etc/data.keyfile
  fi
fi
'';
in
{
   # Only include desktop components if one is supplied.
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  config.users.users.nixos = {
    description = "NixOS";
    extraGroups = [
        "audio"
        "networkmanager"
        "users"
        "video"
        "wheel"
      ]
      ++ ifExists [
        "docker"
        "podman"
      ];
    homeMode = "0755";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC2gvi32T+zdS+0sQNDeiJ8V6JOBO2Nf7glTKIdWrYXEnqbhroxcIOakDA7FkAqXbhNCQLhBakSD8f/lMkWzBddgdrU7tgdOi20CHzbQ9qz23bA6CNXjrqfZY84jjgKJv3PJj51pZYWNvle6fiZ3qeTfdbsa7b+9Mfnwzvq6yypS5lVYbzjIH0W1dto9m8Tw8J/5093Hagcja+je+Whyk6RuSf3CzmvY8DsL/XwS/f+JZjnpsiPr4xJ3mXtQm5R8lKy2NQDAObznjh7ptjogo9iY7Q6L4L5+lXqciaYmu8gr1Ht+QifODgNC/xSJqUDpti3/4Qh1hjczzFH+P6Mc2RVuHmi5X0yhKLWVrwp1dsWr7LAXc6tadaDpSnifqLjvhO3FHYMLEs+NHtvh+N+Aos7aDEmtVl9wEl+Tjrr08FFRuW4N2WHZtBVUuvBZoTbpgbVgjWVcLOFqLu46Y2xo+Lv9tr2DlV+fjVdR4EvV4SC20yC2cyLo78SWH7TgO71F+knk/7eU7ITyT64HPD7pbEvQ5J4Sk7Hr7u5XWfM/wOM0Ot/gxTQYj9kNdx79Tj5Sd3UzGxaZfLUpUXPhBEs1S9/d8hHUCVgKmloXkfetBqLteRE8vjIxAQbO5TG54qM6Bvc7e8ut53BrRDzeZIg28zWq6mesoaCucfFTvh8ZyxMQ== juca@nitro"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };

  config.system.stateVersion = lib.mkForce lib.trivial.release;
  config.environment.systemPackages = [ install-system ];
  config.services.kmscon.autologinUser = "${username}";
}