_: {
  # IOMMU configuration
  boot.kernelParams = ["amd_iommu=on" "pcie_aspm=off"];
  boot.kernelModules = ["kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio"];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:13c2,10de:0fbb
    options kvm ignore_msrs=1
  '';

  boot.postBootCommands = ''
    # Enable VFIO on secondary GPU
    for DEV in "0000:0b:00.0" "0000:0b:00.1"; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
    # Setup Looking Glass shared memory object
    touch /dev/shm/looking-glass
    chown john:kvm /dev/shm/looking-glass
    chmod 660 /dev/shm/looking-glass
  '';

  virtualisation = {
    libvirtd = {
      qemuOvmf = true;
      qemuVerbatimConfig = ''
        namespaces = []
        nographics_allow_host_audio = 1
        user = "john"
        group = "kvm"
      '';
    };
  };
}
