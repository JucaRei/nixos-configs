# Basic NixOS configuration for desktop libvirt virtualization
# This file should be sourced in your /etc/nixos/configuration.nix
# imports declaration.
{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      libguestfs-with-appliance
      libvirt
      libvirt-glib
      virt-manager
    ];
  };

  virtualisation = { libvirtd.enable = true; };
}
