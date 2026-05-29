{
  stdenv,
  coreutils-full,
  gegl,
  gimp2,
  git,
  gnumake,
  icon-slicer,
  which,
  xcursorgen,
  neutrality-src ? ./.,
}:
stdenv.mkDerivation {
  pname = "neutrality";
  version = "git";
  src = neutrality-src;
  nativeBuildInputs = [
    coreutils-full
    gegl.dev
    gimp2
    git
    gnumake
    icon-slicer
    which
    xcursorgen
  ];
  installPhase = ''
    set -x
    installDir="$out/share/icons/$pname";
    install -d "$installDir/cursors"
    cp -r build/theme/* "$installDir"
  '';
}
