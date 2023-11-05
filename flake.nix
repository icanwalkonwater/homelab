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
    inventories = {
      testing = lib.ansible.mkInventory vars.testing;
    };
    writeInventory = system: inv: nixpkgs.legacyPackages.${system}.writeText "inventory.json" inv;

    mkStageBaremetal = (import ./0-baremetal inputsWithLib);

  in flutils.lib.eachDefaultSystem (system: rec {
    packages = rec {
      inventoryTesting = writeInventory system inventories.testing;
      baremetal = mkStageBaremetal system inventoryTesting;
    };

    apps = {
      baremetal = flutils.lib.mkApp {
        drv = packages.baremetal;
      };
    };
  });
}

