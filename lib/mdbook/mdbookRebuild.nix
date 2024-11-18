{ runCommand
, mdbook
, mdbook-mermaid
}:

{ src ? ""
, srcname ? "src" # TODO: Get srcname from the book.toml if present
, title ? ""
  # TODO: Add the option to write book.toml?
  # , book_toml ? { }
  # TODO: Add the option to patch book.toml?
  # , patches ? [ ]
}:
runCommand "mdbookRebuild"
{
  buildInputs = [
    mdbook
    mdbook-mermaid
  ];
} ''
  mkdir -p $out

  if [[ -n "${title}" ]]; then
      mdbook init --title "${title}" $out
  else
      mdbook init $out
  fi

  mdbook-mermaid install $out

  if [[ -n "${src}" ]]; then
      rm -rf $out/src
      cp -a ${src}/${srcname} $out
  fi

  mdbook build $out
''
