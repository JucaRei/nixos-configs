{ lib
, stdenvNoCC
, fantasque-sans-ligatures
, nerd-font-patcher
, python3Packages
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "fantasque-sans-ligatures-nerd";
  version = "1.8.0-${nerd-font-patcher.version}";

  src = fantasque-sans-ligatures;

  nativeBuildInputs =
    [
      nerd-font-patcher
    ]
    ++ (with python3Packages; [
      python
      fontforge
    ]);

  buildPhase = ''
    runHook preBuild

    mkdir -p build/

    for f in share/fonts/opentype/*; do
      nerd-font-patcher $f --complete --no-progressbars --outputdir build
      # note: this will *not* return an error exit code on failure, but instead
      # write out a corrupt file, so an additional check phase is required
    done

    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    # Try to open each font. If a corrupt font was written out, this should fail
    for f in build/*; do
        fontforge - <<EOF
    try:
      fontforge.open(''\'''${f}')
    except:
      exit(1)
    EOF
    done

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype/
    install -Dm 444 build/* $out/share/fonts/opentype/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/ryanoasis/nerd-fonts";
    description = "Ligature-less Fantasque Sans Mono patched with Nerd Fonts icons";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
