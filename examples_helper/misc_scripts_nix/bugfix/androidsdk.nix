## Temporarily needed if Android pkgs doesn't work
{ pkgs ? import <nixpkgs> { config.android_sdk.accept_license = true; } }:
(pkgs.buildFHSUserEnv {
  name = "android-sdk-env";
  targetPkgs = pkgs: (with pkgs; [
    androidenv.androidPkgs_9_0.androidsdk
    glibc
    openjdk11
    nodejs
    yarn
  ]);
  runScript = "bash";

  profile = ''
    export ANDROID_SDK_ROOT=/home/rbozan/Android/Sdk/
  '';
}).env
