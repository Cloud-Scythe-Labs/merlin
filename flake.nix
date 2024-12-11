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

        checks = with pkgs;
          let
            root = ./test_data;
            src = lib.fileset.toSource {
              inherit root;
              fileset = root + "/src";
            };
            testBook = mdbookRebuild {
              inherit src;
              title = "testBook";
            };
          in
          {
            test-mdbookRebuild = testBook;
          } // lib.optionalAttrs stdenv.isLinux {
            test-mdBook-server =
              let
                name = "test-mdBook-server";
              in
              nixpkgs.lib.nixos.runTest {
                inherit name;
                hostPkgs = nixpkgs.legacyPackages.${system};
                nodes.machine = {
                  imports = [ self.nixosModules.${system}.mdBook-server ];
                  environment.systemPackages = [ testBook ];
                  services.merlin.mdBook-server.enable = true;
                  services.merlin.mdBook-server.port = 8080;
                  services.merlin.mdBook-server.src = builtins.trace "'${name}' mdBook path is '${testBook}'" "${testBook}";
                };
                testScript = ''
                  machine.wait_for_unit("merlin-mdBook-server.service");
                  machine.succeed("curl http://localhost:8080");
                '';
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
            default = builtins.trace "Generated mdBook path is '${mdbook-rebuild}'" mdbook-rebuild;
          };

        nixosModules.mdBook-server = { config, lib, pkgs, ... }: {
          imports = [ ./nixos/modules ];
          services.merlin.mdBook-server.package = lib.mkDefault self.packages.${system}.mdbook;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nil
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
