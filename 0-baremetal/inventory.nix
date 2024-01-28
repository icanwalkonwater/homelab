{inputs, ...}: let
  nixpkgs = inputs.nixpkgs;
  lib = nixpkgs.lib;
in {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.baremetalAnsibleInventory = let
      vm = import ./vm.nix;
      hosts = lib.pipe {inherit vm;} [
        (builtins.mapAttrs (
          name: host: (lib.filterAttrs (key: v: builtins.elem key ["ansible_host" "partitions" "filesystems" "chrootMounts" "nixosConfiguration"]) host)
        ))
      ];
    in
      pkgs.writeTextFile {
        name = "inventory.yml";
        text = builtins.toJSON {
          all = {
            inherit hosts;
            vars = {
              ansible_user = "ansible";
              ansible_ssh_private_key_file = self'.packages.ansibleSshPrivateKey;
              nixos_configuration_flake_url = "github:icanwalkonwater/homelab#vm";
            };
          };
        };
      };

    packages.baremetalDebugAnsibleInventory = pkgs.writeShellApplication {
      name = "debug-ansible-inventory";
      runtimeInputs = [pkgs.ansible];
      text = ''
        export LC_ALL=C.UTF-8
        ansible-inventory -i ${self'.packages.baremetalAnsibleInventory} --graph --vars
      '';
    };
  };
}
