{ flutils, lib, ... }: with lib.specHelpers; {
  vm0 = {
    groups = [groups.k8sMaster];
    system = flutils.lib.system.x86_64-linux;
    ip = "192.168.100.200";
    mac = "52:54:00:21:f3:2b";
    diskLayout = let 
      boot = mkDiskLayoutBoot { device = toString /dev/disk/by-id/ata-QEMU_HARDDISK_QM00001; };
      storagePool = mkDiskLayoutBig {
        devices = [
          (toString /dev/disk/by-id/ata-QEMU_HARDDISK_QM00003)
          (toString /dev/disk/by-id/ata-QEMU_HARDDISK_QM00005)
        ];
        label = "lucastrunk";
        subvolumes = [
          "@media"
          "@media/@staging"
          "@media/@storage"
          "@minecraft"
          "@snapshots"
        ];
        mountPoint = toString /mnt/trunk;
      };
    in {
      # Its a VM, we don't care
      options.overridePartitionTables = true;
      partitionTables = boot.partitionTables ++ storagePool.partitionTables;
      fileSystems = boot.fileSystems ++ storagePool.fileSystems;
      mountPoints = boot.mountPoints ++ storagePool.mountPoints;
    };
  };
}
