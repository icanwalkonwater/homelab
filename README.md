# Homelab - Lucasfilm

Source files for my homelab, a 2 nodes kubernetes cluster running a few apps and a minecraft modded server.

<hr>

There are currently 2 nodes:
- `coruscant`: big boy x86 machine with both fast (SSD) and slow (btrfs array of hard drives) storage.
  - Its configuration can be found at `nixos/coruscant/configuration.nix`.
- `mortis`: a RPI 3B+ connected to a 3D printer.

## Instalation

Needs a working k3s cluster without traefik or local-storage.

The cluster is fully managed by `argocd` but first we need to manually install the first time, and then it can manage itself and the rest of the cluster:
```bash
kubeclt apply -k argocd
```

Overview of the main components:
- `argocd`: for managing the cluster in a declarative way.
- `ingress-nginx`: as Ingress controller.
- `cert-manager`: with Lets encrpyt as issuer to manage TLS certificates.
- `local-path-provisioner`: allows the dynamic creation of PVs without complicated distributed storage.
- `sealed-secrets`: to safely store secrets in this public repo in an encrypted way.
- `lldap`+`authelia`: for authentification and securing apps.
- `prometheus`+`node-exporter`+`grafana`: as the basic monitoring stack.

Apps installed:
- `mealie`: cooking recipes database.
- `octoprint`: for managing my 3D printer remotely.
- `minecraft-gtnh`: a GregTech: New Horizons minecraft modded server.
