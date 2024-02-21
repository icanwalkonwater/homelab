{
  inputs,
  self,
  ...
}: let
  lib = inputs.nixpkgs.lib;
in {
  flake = {
    nixosConfigurations.vm = lib.nixosSystem {
      specialArgs = inputs;
      modules = with self.nixosModules; [
        vmHardwareConfiguration
        vmFilesystems
        vmDebloat
        enableFlakes
        bootloaderSystemd
        doas
        sshd
        userLucas
        vm
      ];
    };

    nixosModules.vm = {
      modulesPath,
      lib,
      ...
    }: {
      imports = [
        (modulesPath + "/profiles/minimal.nix")
        # (modulesPath + "/profiles/headless.nix")
      ];

      networking.hostName = "vm";
      networking.networkmanager.enable = true;
      networking.firewall.enable = false;

      time.timeZone = "Europe/Paris";

      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "fr";
    };

    nixosModules.vmDebloat = {lib, ...}: {
      appstream.enable = false;
      networking.networkmanager.plugins = lib.mkForce [];
      programs.command-not-found.enable = false;
      programs.nano.enable = false;
      # services.lvm.enable = false;
    };

    nixosModules.vmHardwareConfiguration = {
      modulesPath,
      lib,
      ...
    }: {
      imports = [(modulesPath + "/profiles/qemu-guest.nix")];

      boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod"];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-intel"];
      boot.extraModulePackages = [];

      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      system.stateVersion = "23.11";
    };

    nixosModules.vmFilesystems = {...}: let
      diskByLabel = label: "/dev/disk/by-label/${label}";
    in {
      fileSystems."/boot" = {
        device = diskByLabel "bootloader";
        fsType = "vfat";
      };

      fileSystems."/" = {
        device = diskByLabel "nixos";
        fsType = "btrfs";
        options = ["subvol=@"];
      };

      fileSystems."/nix" = {
        device = diskByLabel "nixos";
        fsType = "btrfs";
        options = ["subvol=@nix"];
      };

      fileSystems."/var/log" = {
        device = diskByLabel "nixos";
        fsType = "btrfs";
        options = ["subvol=@log"];
      };

      fileSystems."/home" = {
        device = diskByLabel "nixos";
        fsType = "btrfs";
        options = ["subvol=@home"];
      };

      fileSystems."/root" = {
        device = diskByLabel "nixos";
        fsType = "btrfs";
        options = ["subvol=@root"];
      };

      swapDevices = [];
    };
  };
}
