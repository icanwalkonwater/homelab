{...}: {
  imports = [./vm.nix];

  flake.nixosModules = {
    enableFlakes = {lib, ...}: {
      config = {
        nix.settings.experimental-features = lib.mkDefault ["nix-command" "flakes"];
      };
    };

    bootloaderSystemd = {...}: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };

    sshd = {...}: {
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "no";
        settings.PasswordAuthentication = false;
      };
    };

    doas = {...}: {
      security.sudo.enable = false;
      security.doas = {
        enable = true;
      };
    };

    userLucas = {...}: {
      users.users."lucas" = {
        isNormalUser = true;
        extraGroups = ["wheel"];

        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrztDvElHynPqE3LQqZ0qjm4uaodWsbc4UUQ2v37ZlfGRZX5LX38/J+B9YmhbUMl7u41ISmqxJy3W1KyEz7IlBhwQN2TYd7zzAXJkyFd4K26MVzMlWNrFq7lF5UykHbilnOTJYwkenUZBOuxrnxXaSZ44J9LC+CVC1oQ0QevHRW/FsFLpeIn2d8eUp8VGp/Gb5++ei7Uk1lTTB4lyApGWRcebaTp+cXPAB3qar9a9f5BPL21vo8BRQYf8d0SjgqgHpwsW7tA6kIcS3QWAVqap23j4tSAou5Atqy5H1K8oFnLRMfvieqAhAdZ9U4ZBV9A0Z4KRBV0bTYYER2cv9BGkVL/hQFS1BfBfRHAinUBB5QPaG/hdvZn2UMg894vIE9kiJ+N79QmoonsGe6vD39skOlhwfNfA6NIvPhbpWXZGuqgBCx7BlCz2WlUwesuxBSRBMaFMcYoGB4b5k3xjPPs8KbBWTwlZymFvIOk3EZvaUOiryNpR9zo2kM5xRDcKXovU="
        ];
      };
    };

    k3sMaster = {pkgs, ...}: {
      services.k3s = {
        enable = true;
        role = "server";
        clusterInit = true;
        extraFlags = toString [
          "--secrets-encryption"
          "--flannel-backend=wireguard-native"
          "--disable-cloud-controller"
          "--disable=traefik"

          # TODO: Fix dual stack

          # "--cluster-cidr=10.42.0.0/16,2001:cafe:42::/56"
          # "--service-cidr=10.43.0.0/16,2001:cafe:43::/112"
          # Workaround to prioritize IPv6 traffic
          # "--kubelet-arg='node-ip=::'"
        ];
      };

      environment.systemPackages = [pkgs.wireguard-tools];
    };
  };
}
