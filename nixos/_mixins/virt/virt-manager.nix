{
  pkgs,
  config,
  username,
  ...
}: {
  boot = {
    extraModprobeConfig = ''
      # Needed to run OSX-KVM
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_nsrs=1

      #Load VFIO related modules
      "options vfio-pci"
      "ids=10de:1c02,10de:10f1"
    '';

    # Load VFIO related modules
    kernelModules = ["vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio"];

    # Enable IOMMU
    kernelParams = ["intel_iommu=on"];
  };
  users.groups.libvirtd.members = ["root" "${username}"];

  environment.systemPackages = with pkgs; [
    virt-manager
    spice-gtk
    swtpm
    virt-viewer
    qemu
    OVMF
    gvfs
  ];
  security.polkit.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = with pkgs; [OVMFFull.fd];
        };
        runAsRoot = true;
        swtpm.enable = true;
      };
      onShutdown = "suspend";
      onBoot = "ignore";
    };
    spiceUSBRedirection.enable = true;
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source =
        config.virtualisation.libvirtd.qemu.package
        + "/share/qemu/edk2-x86_64-secure-code.fd";
    };
  };
}
