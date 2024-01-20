let
  common = import ./common.nix;
in {
  hostname = "homelab-vm-staging";
  ip = "192.168.122.181";

  installer = {
    createPartitions = true;
    overridePartitions = true;

    createFilesystems = true;
  };

  hardware = {
    devices = [(common.rootDeviceUefiBtrfs // {device = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001";})];

    filesystems = [
      common.uefiFilesystem
      common.rootBtrfsFilesystem
    ];

    mountpoints = [] ++ common.bootloaderMountpoint ++ common.rootBtrfsMountpoints;
  };
}
