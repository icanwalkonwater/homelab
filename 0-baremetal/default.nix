{ nixpkgs, ... }@inputs: system: let
  pkgs = nixpkgs.legacyPackages.${system};
in
  inventoryDrv: let
    sshKey = pkgs.stdenv.mkDerivation {
      name = "homelab-sshkey";
      src = null;
      nativeBuildInputs = [pkgs.openssh];
      dontUnpack = true;
      dontPatch = true;
      dontConfigure = true;
      buildPhase = ''
        ssh-keygen -t ecdsa -b 384 -N "" -C "" -f service_account.key
        '';
      installPhase = ''
        mkdir -p $out
        cp ./service_account.key ./service_account.key.pub $out
        '';
    };

    installerUser = "ansible";
    netbootInstaller = (import ./netboot.nix inputs system {
      sshUser = installerUser;
      sshPubKeyFile = (builtins.toPath sshKey) + "/service_account.key.pub";
    });

    sources = pkgs.stdenv.mkDerivation {
      name = "homelab-baremetal-playbook";
      src = ./.;
      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        cp -r ./main.yml ./roles $out
        '';
    };
  in
    pkgs.writeShellApplication {
      name = "homelab-baremetal-playbook-run";
      runtimeInputs = [
        (pkgs.python3.withPackages (ps: [ps.ansible ps.requests]))
        sources
        netbootInstaller
      ];
      text = ''
        export LC_ALL='C.UTF-8'
        export ANSIBLE_HOST_KEY_CHECKING=False
        export ANSIBLE_ROLES_PATH=${sources}/roles

        ansible-playbook \
          --private-key ${sshKey}/service_account.key \
          --inventory ${inventoryDrv} \
          --extra-vars "ansible_user=${installerUser}" \
          --extra-vars "pxe_server_image_archive=${netbootInstaller}" \
          ${sources}/main.yml
        '';
    }
