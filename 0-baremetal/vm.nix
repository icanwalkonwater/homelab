rec {
  hostname = "homelab-vm-staging";
  ip = "192.168.122.181";
  ansible_host = ip;

  partitions = [
    {
      device = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001";
      sfdiskScript = ''
        label: gpt
        name=boot-uefi, size=250M, type=uefi
        name=linux, size=+, type=linux
      '';
      creates = ["/dev/disk/by-partlabel/boot-uefi" "/dev/disk/by-partlabel/linux"];
    }
  ];

  filesystems = [
    {
      device = "/dev/disk/by-partlabel/boot-uefi";
      type = "vfat";
      options = ["-F" "32" "-n" "bootloader"];
      creates = ["/dev/disk/by-label/bootloader"];
    }
    {
      device = "/dev/disk/by-partlabel/linux";
      type = "btrfs";
      options = ["--label" "nixos"];
      creates = ["/dev/disk/by-label/nixos"];
      subvolumes = ["/@" "/@nix" "/@log" "/@home" "/@root" "/@snapshots"];
    }
  ];

  chrootMounts =
    (map (mount: mount // {path = "/mnt${mount.path}";}) rootMounts)
    ++ [
      {
        device = "/dev/disk/by-label/bootloader";
        path = "/mnt/boot";
        type = "vfat";
      }
    ];

  rootMounts = let
    subvols = [
      {
        name = "/@";
        path = "/";
      }
      {
        name = "/@nix";
        path = "/nix";
      }
      {
        name = "/@log";
        path = "/var/log";
      }
      {
        name = "/@home";
        path = "/home";
      }
      {
        name = "/@root";
        path = "/root";
      }
    ];
  in
    map ({
      name,
      path,
    }: {
      device = "/dev/disk/by-label/nixos";
      inherit path;
      type = "btrfs";
      options = ["subvol=${name}"];
    })
    subvols;
}
