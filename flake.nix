{
  description = ''
    Build markdown books with mdBook and mermaid, without the boilerplate.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mkLib = pkgs: import ./lib {
          inherit pkgs;
        };
        merlib = mkLib pkgs;

        mdbook = merlib.mdbook {
          version = "0.4.43";
          sha256 = "sha256-aADNcuIeDef9+a3NOWQxo6IRnKJ6AbkvE4GqvFbubyI=";
          cargoHash = "sha256-8K72sJywMKxX/31SJuCEoacWvHrpkuwGGLXJ9MsDkTE=";
        };
        mdbook-mermaid = merlib.mdbook-mermaid {
          version = "0.14.0";
          hash = "sha256-elDKxtGMLka9Ss5CNnzw32ndxTUliNUgPXp7e4KUmBo=";
          cargoHash = "sha256-BnbllOsidqDEfKs0pd6AzFjzo51PKm9uFSwmOGTW3ug=";
        };
        mdbookRebuild =
          merlib.mdbookRebuild.override {
            inherit
              mdbook
              mdbook-mermaid
              ;
          };
      in
      {
        inherit mkLib;

        checks = {
          testBook = with pkgs;
            let
              root = ./test_data;
              src = lib.fileset.toSource {
                inherit root;
                fileset = root + "/src";
              };
            in
            mdbookRebuild {
              inherit src;
              title = "testBook";
            };
        };

        packages =
          let
            mdbook-rebuild = mdbookRebuild { };
          in
          {
            inherit
              mdbook
              mdbook-mermaid
              mdbook-rebuild
              ;
            default = mdbook-rebuild;
          };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            mdformat
          ] ++ [
            self.packages.${system}.mdbook
            self.packages.${system}.mdbook-mermaid
          ];
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
