{ lib
, stdenv
, fetchFromGitHub
, nix
, rustPlatform
, darwin
, installShellFiles
}:

{ version ? ""
, sha256 ? ""
, cargoHash ? ""
}:
rustPlatform.buildRustPackage rec {
  inherit version cargoHash;
  pname = "mdbook";

  src = fetchFromGitHub {
    inherit sha256;
    owner = "rust-lang";
    repo = "mdBook";
    rev = "refs/tags/v${version}";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mdbook \
      --bash <($out/bin/mdbook completions bash) \
      --fish <($out/bin/mdbook completions fish) \
      --zsh  <($out/bin/mdbook completions zsh )
  '';

  passthru = {
    tests = {
      inherit nix;
    };
  };

  meta = with lib; {
    description = "Create books from MarkDown";
    mainProgram = "mdbook";
    homepage = "https://github.com/rust-lang/mdBook";
    changelog = "https://github.com/rust-lang/mdBook/blob/v${version}/CHANGELOG.md";
    license = [ licenses.mpl20 ];
    maintainers = with maintainers; [ eureka-cpu ];
  };
}
