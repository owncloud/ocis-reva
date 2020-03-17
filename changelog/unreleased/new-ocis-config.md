Change: default to running behind ocis-proxy

We changed the default configuration to integrate better with ocis.

- We use ocis-glauth as the default ldap server on port 9125 with base `dc=example,dc=org`.
- We use a dedicated technical `reva` user to make ldap binds
- Clients are supposed to use the ocis-proxy endpoint `https://localhost:9200`
- We removed unneeded ocis configuration from the frontend which no longer serves an oidc provider.

https://github.com/owncloud/ocis-reva/pull/113