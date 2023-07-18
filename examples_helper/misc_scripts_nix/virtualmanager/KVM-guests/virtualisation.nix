# # Triggers the build of KVM VM's specified into systemd services
## Import this into your servers /etc/nixos/configuration.nix
_: let
  ## Global settings
  KVM-GUESTS = "/KVM/guests";

  ## Triggers a guest build and allows the usage of these VM's as services
  KVM-GUESTS-template = ((import ./kvm.nix) {}).template;
in {
  ## Definitions for running each VM as a service.

  systemd.services."kvm-template" = {
    description = "KVM NixOS Guest - Template Test Setup";
    enable = true;

    wantedBy = ["multi-user.target"];

    environment = {KVM_NAME = "template";};
    script = ''
      VM_STORAGE=${KVM-GUESTS}/$KVM_NAME

      mkdir -p $VM_STORAGE
      cd $VM_STORAGE

      ${KVM-GUESTS-template}/bin/run-$KVM_NAME-vm
    '';
  };
}
