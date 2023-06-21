{
  description = "Android Emulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          system = system;
          config.android_sdk.accept_license = true;
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "cmdline-tools"
              "tools"
            ];
        };

        # options on:
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/mobile/androidenv/compose-android-packages.nix
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          #cmdLineToolsVersion = "8.0";
          includeEmulator = true;
          buildToolsVersions = ["30.0.3" "33.0.2"];
          platformVersions = ["28" "33"];
          abiVersions = ["x86" "x86_64"];
          includeNDK = true;
          includeExtras = [
            "extras;google;gcm"
          ];
          extraLicenses = [];
        };
        androidsdk = androidComposition.androidsdk;

        # FROM: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/compilers/flutter/flutter.nix
        flutter_deps = pkgs:
          with pkgs; [
            bash
            curl
            dart
            git
            unzip
            which
            xz

            # flutter test requires this lib
            #libGLU

            # for native emulator
            #alsa-lib
            #dbus
            #expat
            #libpulseaudio
            #libuuid
            #xorg.libX11
            #xorg.libxcb
            #xorg.libXcomposite
            #xorg.libXcursor
            #xorg.libXdamage
            #xorg.libXext
            #xorg.libXfixes
            #xorg.libXi
            #xorg.libXrender
            #xorg.libXtst
            #libGL
            #nspr
            #nss
            #systemd
          ];

        fhs = pkgs.buildFHSUserEnvBubblewrap {
          name = "flutter-env";
          runScript = "zsh";
          multiPkgs = pkgs:
            with pkgs; [
              # Flutter only use these certificates
              (runCommand "fedoracert" {} ''
                mkdir -p $out/etc/pki/tls/
                ln -s ${cacert}/etc/ssl/certs $out/etc/pki/tls/certs
              '')
              zlib
            ];
          targetPkgs = pkgs:
            with pkgs;
              [
                flutter.passthru.unwrapped
                clang

                # required on flutter doctor
                cmake
                ninja
                pkg-config
                glib
                gtk3 # test with: pkg-config --libs gtk+-3.0

                # required on flutter run
                xorg.xorgproto
                libepoxy
              ]
              ++ (flutter_deps pkgs)
              ++ gtk3.propagatedBuildInputs
              ++ pango.propagatedBuildInputs;
          profile = with pkgs; ''
            export PUB_CACHE=''${PUB_CACHE:-"$HOME/.pub-cache"}
            export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
            export JAVA_HOME="${jdk.home}";
            export ANDROID_JAVA_HOME="${jdk.home}";
            export ANDROID_HOME="${androidsdk}/libexec/android-sdk";
            export ANDROID_SDK_ROOT="${androidsdk}/libexec/android-sdk";
          '';
          extraBwrapArgs = [
            "--proc /proc"
            "--tmpfs /home"
            "--die-with-parent"
            "--bind-try ~/bwrap/flutter ~/"
            "--bind-try ~/projects/codes/flutter ~/projects/codes/flutter"
          ];
          extraOutputsToInstall = ["dev"];
          #extraBuildCommands = ''
          #  mkdir -p $out/bin
          #  mkdir -p $out/bin/cache/
          #  ln -sf ${pkgs.dart} $out/bin/cache/dart-sdk
          #'';
        };
      in {
        devShell = fhs.env;

        # Extra commands:
        # flutter config --no-analytics
        # flutter precache
        # flutter doctor --android-licenses
        # flutter doctor
      }
    );
}
