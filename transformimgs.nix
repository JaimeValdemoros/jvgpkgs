{ pkgs }:
let
  wrapped = pkgs.buildGoModule rec {
    pname = "transformimgs";
    version = "8.11.1";

    src = pkgs.fetchFromGitHub {
      owner = "Pixboost";
      repo = "transformimgs";
      rev = "v${version}";
      hash = "sha256-wT98AlEy+wq7u1hKbRJFBnpuYuvER6y6eNVfmQTiCn0=";
    };

    IM_HOME = "${pkgs.imagemagick}/bin";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.imagemagick ];

    vendorHash = "sha256-0J05hEI7RkJCG35uPkl7gYPDiVQWxmbGwsuDJrDaVk8=";
  };
in
pkgs.runCommand "transformings"
{
  buildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin
  makeWrapper ${wrapped}/bin/cmd $out/bin/transformings \
        --add-flags "-imConvert=${pkgs.imagemagick}/bin/convert" \
        --add-flags "-imIdentify=${pkgs.imagemagick}/bin/identify"
''
