{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { nixpkgs, flake-parts, ... }: flake-parts.lib.mkFlake {inherit inputs;} {
    systems = ["x86_64-linux"];
    perSystem = {system, pkgs, self', ...}: {
      devShells.default = pkgs.mkShell {
        packages = [
          self'.formatter
          pkgs.bash-language-server
          pkgs.yaml-language-server
        ];
      };
      formatter = pkgs.alejandra;
    };
  };
}
