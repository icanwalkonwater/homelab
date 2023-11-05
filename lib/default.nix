{ ... }@inputs: {
  specHelpers = (import ./spec_helpers.nix inputs);
  ansible = (import ./ansible.nix inputs);
}
