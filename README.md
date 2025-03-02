# homelab k3s infra

## Bootstrapping

First install ArgoCD on the cluster: `kubectl apply -k argocd`.

Then create the bootstrap app: `kubectl create -f apps/bootstrap.yml -n argocd`.

Everything should be created or at least queued now.
