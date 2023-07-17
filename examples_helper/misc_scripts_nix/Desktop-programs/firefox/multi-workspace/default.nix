with import <nixpkgs> { };
stdenv.mkDerivation rec {
  name = "url-launcher";

  desktopItem = makeDesktopItem {
    name = "UrlLauncher";
    exec = "@out@/bin/url-launcher %U";
    comment = "Run URL in browser in current workspace";
    desktopName = "UrlLauncher";
    genericName = "Browser launcher";
    categories = "Application;Network;WebBrowser;";
    mimeType = "text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ xdotool wmctrl ];

  buildCommand = ''
    mkdir -p \
       $out/bin \
       $out/share/applications
    cp ${./url-launcher.sh} $out/bin/url-launcher
    chmod +x $out/bin/url-launcher
    wrapProgram $out/bin/url-launcher --prefix PATH : "${lib.makeBinPath buildInputs}"
    cp $desktopItem/share/applications/* $out/share/applications
    substitute $desktopItem/share/applications/* $out/share/applications/UrlLauncher.desktop --subst-var out
  '';
}
