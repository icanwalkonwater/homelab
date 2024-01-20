let
  rootDeviceUefiBtrfs = {
    label = "gpt";
    partitions = [
      {
        label = "boot-uefi";
        size = "250MiB";
        type = "uefi";
      }
      {
        label = "linux";
        size = "+";
        type = "linux";
      }
    ];
  };

  uefiFilesystem = {
    device = "/dev/disk/by-partlabel/boot-uefi";
    label = "bootloader";
    type = "vfat";
    options = ["-F" "32"];
  };

  bootloaderMountpoint = {
    device = "/dev/disk/by-label/bootloader";
    type = "vfat";
    mountpoint = "/boot";
  };

  rootBtrfsSubvolumes = [
    {
      name = "@";
      path = "/";
    }
    {
      name = "@nix";
      path = "/nix";
    }
    {
      name = "@log";
      path = "/var/log";
    }
    {
      name = "@root";
      path = "/root";
    }
    {
      name = "@home";
      path = "/home";
    }
    {name = "@snapshots";}
  ];

  rootBtrfsFilesystem = {
    device = "/dev/disk/by-partlabel/linux";
    type = "btrfs";
    label = "nixos";
    subvolumes = map ({name, ...}: name) rootBtrfsSubvolumes;
  };

  rootBtrfsMountpoints = let
    withMountpoint = builtins.filter (subvol: subvol ? path) rootBtrfsSubvolumes;
  in
    map ({
      name,
      path,
    }: {
      device = "/dev/disk/by-label/nixos";
      type = "btrfs";
      options = ["-o" "subvol=${name}"];
      mountpoint = path;
    })
    withMountpoint;
in {inherit rootDeviceUefiBtrfs uefiFilesystem bootloaderMountpoint rootBtrfsFilesystem rootBtrfsMountpoints;}
