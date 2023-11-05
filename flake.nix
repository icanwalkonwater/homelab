{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    flutils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flutils, nixpkgs, ... }@inputs: let
    lib = (import ./lib inputs);
    inputsWithLib = inputs // { inherit lib; };
    vars = {
      testing = lib.specHelpers.validateHostsSchema (import ./vars_testing.nix inputsWithLib);
    };

    inventoryTesting = lib.ansible.mkInventory vars.testing;
    inventoryDrv = system: inv: nixpkgs.legacyPackages.${system}.writeText "inventory.json" inv;

    baremetalDrv = (import ./0-baremetal inputsWithLib);
  in flutils.lib.eachDefaultSystem (system: rec {
    packages = rec {
      inventory_testing = inventoryDrv system inventoryTesting;
      baremetal = baremetalDrv system inventory_testing;
    };

    apps = {
      test = flutils.lib.mkApp {
        drv = packages.baremetal;
      };
    };
  });
}

