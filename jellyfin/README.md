# Jellyfin

Since its a pain in the ass to provision it, here is a checklist of thing to do to setup the instance.
This assumes that there is a LDAP user named `jellyfin` with read access as well as 2 groups: `jellyfin.viewer` and `jellyfin.admin`

- [ ] Add libraries with default settings
- [ ] General / Server name: Lucasfilm
- [ ] Plugins / LDAP Authentication: Install
- [ ] Plugins / Kodi Sync Queue: Install
- [ ] Wait for scan to end
- [ ] Restart
- [ ] My Plgins / LDAP Auth
  - [ ] LDAP Server: `lldap.auth.svc.cluster.local`
  - [ ] LDAP Port: `3890`
  - [ ] Uncheck Secure LDAP
  - [ ] LDAP Bind User: `uid=jellyfin,ou=people,dc=homelab,dc=icanwalkonwater,dc=dev`
  - [ ] LDAP Bind User Password: the password
  - [ ] LDAP Base DN for searches: `ou=people,dc=homelab,dc=icanwalkonwater,dc=dev`
  - [ ] LDAP Search Filter: `(memberof=cn=jellyfin.viewer,ou=groups,dc=homelab,dc=icanwalkonwater,dc=dev)`
  - [ ] LDAP Search Attributes: `uid, mail`
  - [ ] LDAP Uid Attribute: `uid`
  - [ ] LDAP Username Attribute: `uid`
  - [ ] LDAP Admin Base DN: leave empty
  - [ ] LDAP Admin Filter: `(memberof=cn=jellyfin.admin,ou=groups,dc=homelab,dc=icanwalkonwater,dc=dev)`
  - [ ] Enable User Creation: check
