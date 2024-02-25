# Homelab

## Installation

### PXE boot

```bash
$ nix run .#pxeServer
```

### Baremetal Install

Probe the host and print their disk configuration:
```bash
$ nix run .#baremetalDiscoverHosts
```

Partition them manually or using nix, and install NixOS:
```bash
$ nix run .#baremetalInstall
```

### Kubernetes

Setup ArgoCD and the rest will automatically be deployed.

```bash
$ kubectl apply -k ./2-argocd
```
