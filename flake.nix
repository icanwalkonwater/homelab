{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake = {
        nixosConfigurations.networkInstaller = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.netbootMinimal
            self.nixosModules.netbootPxeFiles
            self.nixosModules.ansibleUser
            ({...}: {
              system.stateVersion = "23.11";
              ansibleUser = {
                enable = true;
                sshPubKey = self.packages.x86_64-linux.ansibleSshPublicKey;
              };
            })
          ];
        };

        nixosModules = {
          netbootMinimal = nixpkgs + "/nixos/modules/installer/netboot/netboot-minimal.nix";

          netbootPxeFiles = {
            config,
            pkgs,
            ...
          }: {
            system.build.cmdline = ''
              init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
            '';

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
          };

          ansibleUser = {
            config,
            pkgs,
            lib,
            ...
          }: {
            options.ansibleUser = {
              enable = lib.mkEnableOption "Enable Ansible User";

              username = lib.mkOption rec {
                type = lib.types.str;
                default = "ansible";
                example = default;
                description = "Name of the user";
              };

              sshPubKey = lib.mkOption {
                type = lib.types.path;
                default = null;
                description = "Public key to remotly connect";
              };
            };

            config = let
              cfg = config.ansibleUser;
            in
              lib.mkIf cfg.enable {
                environment.systemPackages = [pkgs.python3];

                users.mutableUsers = false;
                users.groups.${cfg.username} = {};
                users.users.${cfg.username} = {
                  # Not true but it does what we want
                  isNormalUser = true;
                  openssh.authorizedKeys.keyFiles = [cfg.sshPubKey];
                };

                security.sudo.extraRules = [
                  {
                    users = [cfg.username];
                    commands = [
                      {
                        command = "ALL";
                        options = ["NOPASSWD"];
                      }
                    ];
                  }
                ];
              };
          };
        };
      };

      perSystem = {pkgs, self', ...}: {
        formatter = pkgs.alejandra;

        packages.ansibleSshPrivateKey = pkgs.runCommand "ansible.key" {} ''
          ${pkgs.openssh}/bin/ssh-keygen -t ecdsa -b 384 -f "$out"
        '';
        packages.ansibleSshPublicKey = pkgs.runCommand "ansible.key.pub" {} ''
          ${pkgs.openssh}/bin/ssh-keygen -f ${self'.packages.ansibleSshPrivateKey} -y > "$out"
        '';

        packages.pxeServer = let
          netbootFiles = self.nixosConfigurations.networkInstaller.config.system.build.netbootFiles;
          cmdline = self.nixosConfigurations.networkInstaller.config.system.build.cmdline;
        in
          pkgs.writeShellApplication {
            name = "pxe-server";
            runtimeInputs = [pkgs.pixiecore];
            text = ''
              echo 'Starting pixiecore server'
              pixiecore \
                boot \
                ${netbootFiles}/linux \
                ${netbootFiles}/initrd \
                --cmdline "${cmdline}" \
                --dhcp-no-bind \
                --debug
            '';
          };
      };
    };
}
