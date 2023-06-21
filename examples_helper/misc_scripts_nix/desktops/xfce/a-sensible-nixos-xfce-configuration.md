 # A sensible NixOS Xfce Configuration
 
 NixOS provides good support for the Xfce desktop environment out-of-the-box, but the defaults are minimal. The files in this Gist provide a more complete experience, including a suite of basic software and plugins as well as an optional `home-manager` configuration for theming. 

The key additions to the default Xfce provided by NixOS are:
- Complete bluetooth / audio support with panel indicators and apps
- GDM for rootless XOrg sessions
- Extra Xfce apps for calendaring, disk partitioning, etc.
- Various quality-of-life improving non-essentials