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

  hardwareConfigurationModule = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scssi" "sd_mod"];
    boot.kernelModules = ["kvm-intel"];
  };

  nixosConfiguration = "uwu";

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
