{
  description = "Jaime's nix packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        nushell = import ./nushell.nix {
          inherit pkgs;
        };
      in
      {
        packages = {
          inherit nushell;
        };
        # Format with `nix fmt .`
        formatter = pkgs.nixpkgs-fmt;
        devShell = pkgs.mkShell {
          packages = [ self.formatter.${system} ];
        };
      }
    );
}
