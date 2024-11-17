{ pkgs }:
with pkgs;
let
  mdbook = callPackage ./mdbook { };
  mdbook-mermaid = callPackage ./mdbook-mermaid { };
  mdbook-rebuild = callPackage ./mdbook/rebuild.nix { };
in
{
  inherit
    mdbook
    mdbook-mermaid
    mdbook-rebuild
    ;
}
