{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./lib.nix
        ./0-baremetal
        ./1-nixos
      ];
      systems = ["x86_64-linux"];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ansible ansible-lint];
        };
      };
    };
}
