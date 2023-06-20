# Homelab configs

## Provisionning
The host machine is provisionned using Ansible to install a bunch of stuff including rootless docker.

## Deployment
The deployment uses two docker compose project:
- `lucaslab_meta`: Needs to start first, contains the docker registry that the other images refer to
- `lucaslab`: Contains the actuals apps to deploy

## Testing
To test the provisionning part in particular, a VM is provided, in the form of a Vagrantfile.
