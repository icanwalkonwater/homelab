# Homelab
[![Ansible](https://github.com/icanwalkonwater/homelab/actions/workflows/ansible.yml/badge.svg)](https://github.com/icanwalkonwater/homelab/actions/workflows/ansible.yml)

Trying to setup my homelab from bare metal

## Roadmap
- [x] Boot bare metal machine over the network
    - [x] Pixiecore
- [x] Install archlinux onto them
    - [x] Package mirror: pacoloco
- [x] Setup the OS related tasks
    - [x] Auto download updates (but not install)
    - [x] Auto update mirrors
    - [x] Auto scrub
    - [x] Auto btrfs snapshots
    - [x] Btrfs subvolumes management
        - [x] Boot drive
        - [x] Storage pool
    - [x] Can be reused as a maintenance playbook
- [x] Install k3s
    - [x] Install paru
    - [ ] Shutdown hook to drain the node
    - [ ] Startup hook to uncordon the node
- [x] Install ArgoCD into k3s
    - [x] Make ArgoCD take care of himself
- [ ] Install core services
    - [ ] Nginx
    - [ ] cert-manager
    - [ ] Dahsboard
    - [ ] Prometheus (operator ?)
    - [ ] Grafana
    - [ ] Export metrics
    - [ ] Loki
    - [ ] Export systemd logs
    - [ ] Export syslogs
    - [ ] Container registry
- [ ] Setup SSO
    - [ ] LLDAP
    - [ ] Authelia ? Dex ? Authentik ?
    - [ ] Integrate with Grafana
    - [ ] Integrate with ArgoCD
- [ ] Install apps
    - [ ] Minecraft server GTNH
    - [ ] Jellyfin
    - [ ] arr stack ?
    - [ ] Mealie
    - [ ] Immich
    - [ ] Stirling-pdf
    - [ ] Paperless-ngx

