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
        transformimgs = import ./transformimgs.nix {
          inherit pkgs;
        };
        push-cachix = pkgs.writeShellScriptBin "push-cachix" ''
          set -euo pipefail
          if [ -z ''${CACHIX_AUTH_TOKEN:-} ]; then echo "CACHIX_AUTH_TOKEN env var missing"; exit 1; fi
          echo $CACHIX_AUTH_TOKEN
          # https://docs.cachix.org/pushing
          nix flake archive --json \
            | ${pkgs.jq}/bin/jq -r '.path,(.inputs|to_entries[].value.path)' \
            | ${pkgs.cachix}/bin/cachix push jvgpkgs
          nix build '.#packages.${system}.all' --json \
            | ${pkgs.jq}/bin/jq -r '.[].outputs | to_entries[].value' \
            | ${pkgs.cachix}/bin/cachix push jvgpkgs
          nix develop --profile dev-profile -c true
          cachix push jvgpkgs dev-profile
        '';
      in
      rec {
        packages = {
          inherit nushell transformimgs;
          all = pkgs.symlinkJoin {
            name = "jvgpkgs-all";
            paths = [ nushell transformimgs ];
          };
          default = packages.all;
        };
        # Format with `nix fmt .`
        formatter = pkgs.nixpkgs-fmt;
        devShell = pkgs.mkShell {
          packages = [
            pkgs.cachix
            formatter
            push-cachix
          ];
        };
      }
    );
}
