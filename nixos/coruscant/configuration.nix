# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "coruscant"; # Define your hostname.
  networking.enableIPv6 = true;
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  # Disable user modifications like passwd.
  users.mutableUsers = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPassword = null; # Explicitely disable password.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILunZriCRwN+x3Qlhb+Aj7Z2RtyBFO9Hhr2LZ0eZxodt lucas@ilum"
    ];
  };
  # Lock down root
  users.users.root = {
    hashedPassword = "$6$rounds=1000000$7iaxvgAskJvdGQ5V$2icv5tJgTUjnJgQxL0pabzCX7hXUOdeCvLShWeoQ9zkQN1FIlQMYqUIa6a.62HCKYhQWvy5spt8MX/aj6EDwx/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0/9P2EbuiAEENxpObd8dBjmZJZh7RWoxG1ZvAQP1Yq lucas@ilum"
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    tree
    zellij
    tmux
    wget
    aria2
    htop
    powertop
  ];

  powerManagement.powertop.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    80 # HTTP
    443 # HTTPS
    6443 # K3s supervisor and API Server (Agents -> Servers)
    10250 # Kubelet metrics# K3s Flannel Wireguard IPv4
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # K3s Flannel VXLAN (All -> All)
    51820 # K3s Flannel Wireguard IPv4 (All -> All)
    # 51821 # K3s Flannel Wireguard IPv6 (All -> All)
  ];

  # I don't think this is necessary
  networking.firewall.extraCommands = builtins.concatStringsSep "\n" [
    "iptables -A OUTPUT -p tcp -s 10.42.0.0/16 -j ACCEPT" # K3s pod traffic
    # "ip6tables -A OUTPUT -p tcp -s 2001:db8:42::/56 -j ACCEPT" # K3s pod traffic
    "iptables -A OUTPUT -p tcp -s 10.43.0.0/16 -j ACCEPT" # K3s services traffic
    # "ip6tables -A OUTPUT -p tcp -s 2001:db8:43::/112 -j ACCEPT" # K3s services traffic
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/mnt/rootfs" "/mnt/lucastrunk"];
  };

  networking.wireguard.enable = true;
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = false; # Keep using sqlite instead of HA etcd
    gracefulNodeShutdown.enable = true;
    extraFlags = toString [
      "--flannel-backend=wireguard-native"
      # "--flannel-ipv6-masq"
      "--data-dir=/var/lib/rancher/k3s"
      # "--etcd-snapshot-dir=/mnt/lucastrunk/@k3s/@etcd-snapshots"
      "--disable-cloud-controller"
      "--disable=local-storage,traefik"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
      # "--cluster-cidr=10.42.0.0/16,2001:db8:42::/56"
      # "--service-cidr=10.43.0.0/16,2001:db8:43::/112"
      # "--kubelet-arg='node-ip=0.0.0.0'"
    ];
  };
}
