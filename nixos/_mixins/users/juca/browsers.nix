{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs.unstable; [
    #brave
    #google-chrome
    #microsoft-edge
    #netflix
    #opera
    #vivaldi
    #vivaldi-ffmpeg-codecs
    #wavebox
  ];

  programs = {
    chromium = {
      enable = false;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
        "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        "edlifbnjlicfpckhgjhflgkeeibhhcii" # Screenshot Tool
      ];
      extraOpts = {
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "BuiltInDnsClientEnabled" = false;
        "​DeviceMetricsReportingEnabled" = true;
        "​ReportDeviceCrashReportInfo" = false;
        "PasswordManagerEnabled" = false;
        "​SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "pt-BR"
          "en-GB"
          "en-US"
        ];
        "VoiceInteractionHotwordEnabled" = false;
      };
    };
    firefox = {
      enable = lib.mkForce true;
      languagePacks = ["en-GB" "pt-BR"];
      package = pkgs.unstable.firefox;
    };
  };
}
