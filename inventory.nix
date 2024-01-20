{inputs, ...}: let
  nixpkgs = inputs.nixpkgs;
  lib = nixpkgs.lib;
in {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.ansibleInventory = let
      hosts = import ./hosts;

      makeOptionalMac = host: lib.optionalAttrs (host ? mac) {mac = host.mac;};

      makeOptionalParitionning = host:
        if !(host.installer.createPartitions or false)
        then {}
        else if builtins.length (host.hardware.devices or []) == 0
        then throw "Partition creation requested but `hardware.devices` is empty"
        else let
          devices = host.hardware.devices;

          makeSfdiskScript = label: partitions: ''
            label: ${label}
            ${builtins.concatStringsSep "\n" (map ({
              size,
              label,
              type ? "linux",
            }: ''size=${size}, name=${label}, type=${type}'')
            partitions)}
          '';
        in {
          partitions = map ({
            device,
            label ? "gpt",
            partitions ? [],
          }:
            if label != "gpt"
            then throw "Only `gpt` partitions are supported"
            else if builtins.length partitions == 0
            then throw "No partitions specified, this is likely a bug with you"
            else {
              inherit device;
              wipe_before = host.installer.overridePartitions or false;
              sfdisk_script = makeSfdiskScript label partitions;
              creates = map ({label, ...}: "/dev/disk/by-partlabel/${label}") partitions;
            })
          devices;
        };

      makeOptionalFormatting = host:
        if !(host.installer.createFilesystems or false)
        then {}
        else if builtins.length (host.hardware.filesystems or []) == 0
        then throw "Filesystem creation requested but `hardware.filesystems` is empty"
        else let
          filesystems = host.hardware.filesystems;

          makeFormattingEntry = {
            device,
            type ? "ext4",
            label ? null,
            options ? [],
            ...
          }:
            if !builtins.elem type ["vfat" "ext4" "btrfs"]
            then throw "Only `vfat`, `ext4` and `btrfs` are supported"
            else
              {
                inherit device;
                fstype = type;
                options =
                  options
                  ++ (lib.optionals (label != null) (
                    []
                    ++ (lib.optionals (type == "vfat") ["-n" label])
                    ++ (lib.optionals (builtins.elem type ["ext4" "btrfs"]) ["-L" label])
                  ));
              }
              // (lib.optionalAttrs (label != null) {creates = "/dev/disk/by-label/${label}";});

          asBtrfsSubvolumes = {
            device,
            type ? null,
            subvolumes ? [],
            ...
          }:
            lib.optionals (type == "btrfs") (map (name: {inherit device name;}) subvolumes);
        in {
          filesystems = map makeFormattingEntry filesystems;
          subvolumes = lib.flatten (map asBtrfsSubvolumes filesystems);
        };

      hostConfig = lib.pipe hosts [
        (builtins.mapAttrs (
          name: host:
            {ansible_host = host.ip;}
            // (makeOptionalMac host)
            // (makeOptionalParitionning host)
            // (makeOptionalFormatting host)
        ))
      ];
    in
      pkgs.writeTextFile {
        name = "inventory.yml";
        text = builtins.toJSON {
          all.vars = {
            ansible_user = "ansible";
            ansible_ssh_private_key_file = self'.packages.ansibleSshPrivateKey;
          };
          unconfigured.hosts = hostConfig;
        };
      };

    packages.debugAnsibleInventory = pkgs.writeShellApplication {
      name = "debug-ansible-inventory";
      runtimeInputs = [pkgs.ansible];
      text = ''
        export LC_ALL=C.UTF-8
        ansible-inventory -i '${self'.packages.ansibleInventory}' --graph --vars
      '';
    };
  };
}
