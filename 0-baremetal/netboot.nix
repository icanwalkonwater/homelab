{ nixpkgs, ... }: system: { sshUser, sshPubKeyFile }: let
  pkgs = nixpkgs.legacyPackages.${system};

  nixosConfiguration = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      (nixpkgs + "/nixos/modules/installer/netboot/netboot-minimal.nix")

      ({ config, pkgs, ... }: {
        system.stateVersion = "23.05";

        # Utility to get the kernel command line
        system.build.cmdline = ''
          init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
        '';

        # This groups the various parts of the netboot files into one derivation
        system.build.netbootFiles = pkgs.linkFarm "netboot-files" [
          {
            name = "linux";
            path = "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";
          }
          {
            name = "initrd";
            path = "${config.system.build.netbootRamdisk}/initrd";
          }
        ];
      })

      # Configure the installer
      ({ config, pkgs, ... }: {
        # Install python
        environment.systemPackages = [ pkgs.python3 ];

        # Allows ansible to connect to the installer
        users.groups.${sshUser} = { };
        users.users.${sshUser} = {
          group = "${sshUser}";
          isSystemUser = true;

          createHome = true;
          home = "/home/${sshUser}";

          useDefaultShell = true;

          hashedPassword = null;
          openssh.authorizedKeys.keyFiles = [ sshPubKeyFile ];
        };

        # Grant passwordless sudo to the ansible user
        security.sudo.extraRules = [
          {
            users = [ "ansible" ];
            commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
          }
        ];
      })
    ];
  };
in let
  netbootFiles = nixosConfiguration.config.system.build.netbootFiles;
in pkgs.dockerTools.buildLayeredImage {
  name = "pxe-server-full";
  tag = "latest";
  contents = [
    pkgs.pixiecore
    netbootFiles
  ];
  maxLayers = 32;
  config = {
    Entrypoint = "/bin/pixiecore";
    Cmd = [
      "boot"
      "${netbootFiles.out}/linux"
      "${netbootFiles.out}/initrd"
      "--cmdline" nixosConfiguration.config.system.build.cmdline
      "--dhcp-no-bind"
      "--debug"
    ];
  };

}
