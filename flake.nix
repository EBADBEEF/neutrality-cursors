{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
    };
    nativeBuildInputs = with pkgs; [
      coreutils-full
      gegl.dev
      gimp
      git
      gnumake
      icon-slicer
      which
      xorg.xcursorgen
    ];
  in rec {
    devShells.default = pkgs.mkShell {
      inherit nativeBuildInputs;
    };
    apps.default = {
      type = "app";
      program = (pkgs.writeShellScript "build" ''
        export PATH="${pkgs.lib.makeBinPath nativeBuildInputs}:$PATH"
        exec make "$@"
      '').outPath;
    };
    packages.default = pkgs.stdenv.mkDerivation rec {
      pname = "neutrality";
      version = "git";
      inherit nativeBuildInputs;
      src = self;
      buildPhase = apps.default.program;
      installPhase = let
        installDir="$out/share/icons/${pname}";
      in ''
        install -d "${installDir}/cursors"
        cp -r build/theme/* "${installDir}"
      '';
    };
  });
}
