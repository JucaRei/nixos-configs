{
  config,
  pkgs,
  ...
}: {
  system.build.uboot = pkgs.buildUBoot rec {
    defconfig = "nanopi-m4-rk3399_defconfig";
    extraMeta.platforms = ["aarch64-linux"];
    enableParallelBuilding = true;
    BL31 = "${pkgs.armTrustedFirmwareRK3399}/bl31.elf";
    filesToInstall = ["u-boot-rockchip.bin" ".config"];
    patches = [./hax.patch];
    extraConfig = ''
      CONFIG_FS_BTRFS=y
      CONFIG_CMD_BTRFS=y
      CONFIG_LOGLEVEL=7
      CONFIG_CMD_LOG=y
      CONFIG_LOG=y
      CONFIG_LOG_MAX_LEVEL=8
      CONFIG_LOG_DEFAULT_LEVEL=4
      CONFIG_LOG_CONSOLE=y
      CONFIG_LOGF_FILE=y
      CONFIG_LOGF_LINE=y
      CONFIG_LOGF_FUNC=y
      CONFIG_LOG_ERROR_RETURN=y
    '';
  };
  hardware.firmware = [config.system.build.uboot];
}
