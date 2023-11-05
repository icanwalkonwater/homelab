{ nixpkgs, flutils, ... }: {
  validateHostsSchema = spec:
    assert builtins.isAttrs spec;
  let
    validateHost = { groups ? [], system, ip, mac, diskLayout ? [] }:
      assert builtins.isList groups;
      assert builtins.all builtins.isString groups;
      assert builtins.elem system flutils.lib.allSystems;
      assert builtins.isString ip;
      assert builtins.isString mac;
    {
      inherit groups system ip mac;
      diskLayout = validateDiskLayout diskLayout;
    };

    validateDiskLayout = { options ? null, partitionTables ? [], fileSystems ? [], mountPoints ? [] }:
    {
      options = validateOptions options; 
      partitionTables = builtins.map validatePartitionTable partitionTables;
      fileSystems = builtins.map validateFileSystem fileSystems;
      mountPoints = builtins.map validateMountPoint mountPoints;
    };

    validateOptions = { overridePartitionTables ? false }:
      assert builtins.isBool overridePartitionTables;
      { inherit overridePartitionTables; };

    validatePartitionTable = { device, label ? "gpt", partitions }:
      assert builtins.isPath (/. + device);
      assert label == "gpt";
    {
      inherit device label;
      partitions = builtins.map validatePartition partitions;
    };

    validatePartition = { size, type, label }@part:
      assert builtins.isString size;
      assert builtins.elem type ["uefi" "linux"];
      assert builtins.isString label;
      part;
    
    validateFileSystem = { devices, type, options, subvolumes ? [] }@fs:
      assert builtins.length devices > 0;
      assert builtins.all builtins.isString devices;
      assert builtins.isString type;
      assert builtins.isString options;

      assert builtins.length devices > 1 -> type == "btrfs";
      assert builtins.length subvolumes > 0 -> type == "btrfs";
      assert builtins.all builtins.isString subvolumes;
      fs;

    validateMountPoint = { device, type, mountPoint, options ? null }@mnt:
      assert builtins.isString device;
      assert builtins.isString type;
      assert builtins.isString mountPoint;
      assert options != null -> builtins.isString options;
      mnt;

  in builtins.mapAttrs (hostname: spec: validateHost spec) spec;

  # Standard groups
  groups = {
    k8sNode = "k8sNode";
    k8sMaster = "k8sMaster";
  };

  # Make a set for a common boot drive
  mkDiskLayoutBoot = { device }:
    assert builtins.typeOf device == "string";
  let
    subvolumes = [
      { name = "@"; mountPoint = toString /.; }
      { name = "@nix"; mountPoint = toString /nix; }
      { name = "@log"; mountPoint = toString /log; }
      { name = "@root"; mountPoint = toString /root; }
      { name = "@home"; mountPoint = toString /home; }
      { name = "@snapshots"; }
    ];
  in {
    partitionTables = [{
      inherit device;
      label = "gpt";
      partitions = [
        { size = "256MiB"; type = "uefi"; label = "boot"; }
        { size = "+"; type = "linux"; label = "root"; }
      ];
    }];

    fileSystems = [
      { devices = [(toString /dev/disk/by-partlabel/boot)]; type = "vfat"; options = "-F 32 -n boot"; }

      {
        devices = [(toString /dev/disk/by-partlabel/root)];
        type = "btrfs";
        options = "--label nixos";
        subvolumes = builtins.map ({ name, ... }: name) subvolumes;
      }
    ];

    mountPoints = (map ({ name, mountPoint }: {
      device = toString /dev/disk/by-label/nixos;
      type = "btrfs";
      inherit mountPoint;
      options = "subvol=${name}";
    }) (builtins.filter (s: builtins.hasAttr "mountPoint" s) subvolumes))
      ++
    [
      {
        device = toString /dev/disk/by-label/nixos;
        type = "btrfs";
        mountPoint = toString /mnt/rootfs;
      }
      {
        device = toString /dev/disk/by-label/boot;
        type = "vfat";
        mountPoint = toString /boot;
      }
    ];
  };

  # Make a layout for a big drive bay
  mkDiskLayoutBig = { devices, label, subvolumes ? [], mountPoint }:
    assert (builtins.length devices) >= 2;
    assert (builtins.all (d: builtins.typeOf d == "string") devices);
    assert builtins.all builtins.isString subvolumes;
    assert builtins.typeOf mountPoint == "string";
  {
    partitionTables = (nixpkgs.lib.lists.imap0 (i: device: {
      inherit device;
      label = "gpt";
      partitions = [{ size = "+"; type = "linux"; label = "${label}-${toString i}"; }];
    }) devices);

    fileSystems = [{
      devices = builtins.genList (i: "/dev/disk/by-partlabel/${label}-${toString i}") (builtins.length devices);
      type = "btrfs";
      options = "--label ${label} --data raid1 --metadata raid1";
      inherit subvolumes;
    }];

    mountPoints = [{
      device = "/dev/disk/by-label/${label}";
      type = "btrfs";
      inherit mountPoint; 
    }];
  };

}
