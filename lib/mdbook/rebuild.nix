# TODO: Add if statements for when inputs are null
# TODO: Add the ability to patch the book.toml
# TODO: Break this into a script that can be run for those
# that prefer to have the source, which can then also be used
# here in the runCommand.
{ runCommand
, mdbook
, mdbook-mermaid
}:

{ src ? null
, title ? null
}:
runCommand "mdbook-rebuild" {
  buildInputs = [
    mdbook
    mdbook-mermaid
  ];
} ''
  mkdir -p $out
  mdbook init --title "${title}" $out
  mdbook-mermaid install $out
  rm -rf $out/src       # remove the generated src
  cp -a ${src}/src $out # and replace it with src
  mdbook build $out
''
