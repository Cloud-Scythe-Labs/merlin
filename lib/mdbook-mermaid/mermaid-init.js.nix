{ writeTextFile }:
let
  name = "mermaid-init.js";
in
writeTextFile {
  inherit name;
  text = builtins.readFile ../../${name};
}
