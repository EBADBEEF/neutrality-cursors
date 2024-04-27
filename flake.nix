{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };
  outputs = { self, nixpkgs }: let
    inherit (nixpkgs.lib) foldAttrs mergeAttrs mapAttrs;
    systems = nixpkgs.lib.systems.flakeExposed;
    # eachSystem [ "s1" "s2" ] (system: { one.two = 12; }) => { one.s1.two = 12; one.s2.two = 12; }
    eachSystem = f: foldAttrs mergeAttrs { } (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
  in eachSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
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
  in {
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
      src = self;
      inherit nativeBuildInputs;
      buildPhase = self.apps.${system}.default.program;
      installPhase = ''
        installDir="$out/share/icons/$pname";
        install -d "$installDir/cursors"
        cp -r build/theme/* "$installDir"
      '';
    };
  });
}
