{inputs, ...}: let
  lib = inputs.nixpkgs.lib;
in {
  flake.nixosConfigurations.vm = lib.nixosSystem {};
}
