{ nixpkgs, ... }: {
  mkInventory = hosts: (builtins.toJSON (let
    groupAll = {
      all.hosts = nixpkgs.lib.attrsets.mapAttrs (name: host: {
        ansible_host = host.ip;
        mac = host.mac;
        disk_layout = host.diskLayout;
      }) hosts;
    };

    groupNames = nixpkgs.lib.lists.unique (builtins.concatLists (builtins.catAttrs "groups" (builtins.attrValues hosts)));
    hostnamesAndGroups = builtins.attrValues (nixpkgs.lib.attrsets.mapAttrs (name: { groups, ... }: { inherit name groups; }) hosts);

    collectHostnamesForGroup = group: let
      validHosts = builtins.filter ({ groups, ... }: builtins.elem group groups) hostnamesAndGroups;
    in
      builtins.listToAttrs (builtins.map ({ name, ... }: { inherit name; value = {}; }) validHosts);

    groups = builtins.listToAttrs (builtins.map (group: { name = group; value.hosts = collectHostnamesForGroup group; }) groupNames);
  in
    groupAll // groups
  ));
}
