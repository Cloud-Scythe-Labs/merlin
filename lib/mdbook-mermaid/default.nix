{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, darwin
}:

{ version ? ""
, hash ? ""
, cargoHash ? ""
}:
rustPlatform.buildRustPackage rec {
  inherit version cargoHash;
  pname = "mdbook-mermaid";

  src = fetchFromGitHub {
    inherit hash;
    owner = "badboy";
    repo = pname;
    rev = "refs/tags/v${version}";
  };

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ];

  meta = with lib; {
    description = "A preprocessor for mdbook to add mermaid.js support";
    mainProgram = "mdbook-mermaid";
    homepage = "https://github.com/badboy/mdbook-mermaid";
    changelog = "https://github.com/badboy/mdbook-mermaid/blob/v${version}/CHANGELOG.md";
    license = licenses.mpl20;
    maintainers = with maintainers; [ eureka-cpu ];
  };
}
