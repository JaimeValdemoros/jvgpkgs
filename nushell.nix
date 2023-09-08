{ pkgs }:
let
  nushell' = pkgs.rustPlatform.buildRustPackage rec {
    pname = "nushell";
    version = "0.84.0";

    src = pkgs.fetchCrate {
      pname = "nu";
      inherit version;
      sha256 = "sha256-ygcfS7GEZp0AHzv1pBlTNK6my7XlGTtCrkONcCRMbK8=";
    };

    doCheck = false;
    cargoHash = "sha256-08WtuXVSfA5Vs5lRQx69gnLoxIit69z36vtBOQxXFOM=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];
  };
in
pkgs.symlinkJoin {
  name = "nushell";
  paths = [ nushell' ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/nu \
        --add-flags "--no-config-file"
  '';
}
