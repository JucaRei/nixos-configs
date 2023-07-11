{ pkgs, config, lib, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      # package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_legacy470;
      # package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_stable_open;
      # package = pkgs.linuxKernel.packages.linux_zen.nvidia_x11;

      #open = true;  #opensource
      nvidiaSettings = false;
      nvidiaPersistenced = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        # Bus ID of the Intel GPU
        # Find it using lspci, either under 3D or VGA
        inherit intelBusId;

        # Bus ID of the Nvidia GPU
        # Find it using lspci, either under 3D or VGA
        inherit nvidiaBusId;

        #reverseSync = true;
        sync.enable = true; # will be always on and used for all rendering
      };

      allowExternalGpu =
        false; # Configure X to allow external NVIDIA GPUs when using Prime [Reverse] sync optimus.

      # Useful for when NixOS has issues finding the primary display
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      #forceFullCompositionPipeline = true;
    };
  };
  environment.systemPackages = with pkgs; [
    nvidia-offload
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
  # sessionVariables.NIXOS_OZONE_WL = "1"; # Fix for electron apps with wayland
  # Wayland
  # variables = {
  #   GBM_BACKEND = "nvidia-drm";
  #   LIBVA_DRIVER_NAME = "nvidia";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  # };

  boot.blacklistedKernelModules = lib.mkForce [ "nouveau" ];
}
