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
      gegl
      gimp
      git
      gnumake
      icon-slicer
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
    packages.default = pkgs.stdenv.mkDerivation {
      pname = "neutrality";
      version = "git";
      inherit nativeBuildInputs;
      src = ./.;
      #builder = apps.default.program;
      dontUnpack = true;
      buildPhase = ''
        echo buildphase
        pwd
      '';
      installPhase = ''
        echo mooooooo
      '';
    };
  });
}
