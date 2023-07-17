## Builder for NixOS configurations defined at the end of the file to be built into KVM VM's
{ system ? builtins.currentSystem }:
let
  loadcfg = cfgfile: { config
                     , ...
                     }: {
    imports = [ <nixos/modules/virtualisation/qemu-vm.nix> cfgfile ];
    config = {
      networking.extraHosts = ''
        176.32.0.254 template
      '';
      networking.nameservers = [ "10.50.253.1" "10.51.0.1" "10.51.0.2" "8.8.8.8" ];
      networking.defaultGateway = "176.32.0.1";
      networking.enableIPv6 = false;
      networking.useDHCP = false;

      virtualisation = {
        graphics = false;
      };
    };
  };
  mkcfg = cfgfile:
    import <nixos/lib/eval-config.nix> {
      inherit system;
      modules = [ (loadcfg cfgfile) ];
    };
in
{
  template = (mkcfg ./template.nix).config.system.build.vm;
}
