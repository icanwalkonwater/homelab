{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/ff7b65b44d01cf9ba6a71320833626af21126384";
  };

  outputs = { nixpkgs, flake-utils, ... }: 
    # Be "generic" over the system architecture.
    # In reality we don't care 'its just easier to not have to type x86_64-linux each time.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        # Create a nixos configuration based on the netboot installer
        nixosConfigurations.netboot-installer = nixpkgs.lib.nixosSystem {
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
              users.groups.ansible = { };
              users.users.ansible = {
                name = "ansible";
                group = "ansible";
                isSystemUser = true;

                createHome = true;
                home = "/home/ansible";

                useDefaultShell = true;

                hashedPassword = null;
                openssh.authorizedKeys.keyFiles = [ ./authorized_key.pub ];
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

        packages.netboot = nixosConfigurations.netboot-installer.config.system.build.netbootFiles;

        # Make a docker image with pixiecore serving our netboot files
        packages.docker =
          pkgs.dockerTools.buildLayeredImage {
            name = "pxe-server-full";
            tag = "latest";
            contents = [
              pkgs.pixiecore
              packages.netboot
            ];
            maxLayers = 32;
            config = {
              Entrypoint = "/bin/pixiecore";
              Cmd = [
                "boot"
                "${packages.netboot.out}/linux"
                "${packages.netboot.out}/initrd"
                "--cmdline"
                nixosConfigurations.netboot-installer.config.system.build.cmdline
                "--dhcp-no-bind"
                "--debug"
              ];
            };
          };

      }
    );
}
