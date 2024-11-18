{ pkgs }:
with pkgs;
let
  mdbook = callPackage ./mdbook { };
  mdbook-mermaid = callPackage ./mdbook-mermaid { };
  mdbookRebuild = callPackage ./mdbook/mdbookRebuild.nix { };
in
{
  inherit
    mdbook
    mdbook-mermaid
    mdbookRebuild
    ;
}
