let
  common = import ./common.nix;
in rec {
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

  nixosConfiguration = "uwu";

  # filesystems = [
  #   {
  #     device = "/dev/disk/by-partlabel/boot-uefi";
  #     fstype = "vfat";
  #     options = ["-F" "32" "-n" "bootloader"];
  #   }
  # ];

  # hardware = {
  #   devices = [(common.rootDeviceUefiBtrfs // {device = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001";})];
  #
  #   filesystems = [
  #     common.uefiFilesystem
  #     common.rootBtrfsFilesystem
  #   ];
  #
  #   mountpoints = [] ++ common.bootloaderMountpoint ++ common.rootBtrfsMountpoints;
  # };
}
