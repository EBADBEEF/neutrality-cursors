{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };
  outputs = { self, nixpkgs }: let
    inherit (nixpkgs.lib) foldAttrs mergeAttrs mapAttrs;
    systems = nixpkgs.lib.systems.flakeExposed;
    # eachSystem [ "s1" "s2" ] (system: { one.two = 12; }) => { one.s1.two = 12; one.s2.two = 12; }
    eachSystem = f: foldAttrs mergeAttrs { } (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);

    package = import ./package.nix;

    perSystemOutputs = eachSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        realizedPackage = pkgs.callPackage package { neutrality-src = self; };
      in {
        # 'nix run' shouldn't do anything
        apps.default = null;

        # 'nix develop' will give a shell to run build in local directory
        devShells.default = pkgs.mkShell {
          inherit (realizedPackage) nativeBuildInputs;
        };

        # 'nix develop .#build' will build in local directory
        devShells.build = pkgs.mkShell {
          inherit (realizedPackage) nativeBuildInputs;
          shellHook = ''
            exec make
          '';
        };

        # 'nix build' will build the package
        packages.default = realizedPackage;
      });

    genericOutputs = {
      # The overlay can be used as an input in a nixosSystem flake to add
      # pkgs.neutrality. Found out about the 'composeManyExtensions' pattern
      # from the poetry2nix flake.
      overlays.default = nixpkgs.lib.composeManyExtensions [
        (final: prev: {
          neutrality = final.callPackage package { neutrality-src = self; };
        })
      ];

      # But also export the package function itself in case the user wants to
      # construct their own overlay with callPackage.
      inherit package;

      # Another option could be to create a nixosModules.neutrality here to
      # automatically populate config.environment.systemPackages
    };

  in perSystemOutputs // genericOutputs;
}
