{...}: {
  imports = [./vm.nix];

  flake.nixosModules = {
    bootloaderSystemd = {...}: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };

    sshd = {...}: {
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "no";
        settings.PasswordAuthentification = false;
      };
    };

    doas = {...}: {
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
  };
}
